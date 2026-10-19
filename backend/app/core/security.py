import uuid
from datetime import UTC, datetime, timedelta
from typing import Any

import jwt
from argon2 import PasswordHasher
from argon2.exceptions import VerifyMismatchError
from fastapi import Depends, Header
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.core.database import get_db
from app.core.errors import ForbiddenException, UnauthorizedException

ph = PasswordHasher(
    time_cost=3,
    memory_cost=65536,  # 64 MB
    parallelism=4,
    hash_len=32,
    salt_len=16,
)

security_scheme = HTTPBearer(auto_error=False)


def hash_password(password: str) -> str:
    """Hash password using Argon2id."""
    return ph.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify password against Argon2id hash."""
    try:
        return ph.verify(hashed_password, plain_password)
    except VerifyMismatchError:
        return False
    except Exception:
        return False


def create_access_token(
    subject: str,
    extra_claims: dict[str, Any] | None = None,
    expires_delta: timedelta | None = None,
) -> str:
    """Generate signed JWT access token."""
    expire = datetime.now(UTC) + (
        expires_delta or timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    )
    payload: dict[str, Any] = {
        "sub": subject,
        "exp": expire,
        "iat": datetime.now(UTC),
        "type": "access",
    }
    if extra_claims:
        payload.update(extra_claims)

    return jwt.encode(payload, settings.SECRET_KEY, algorithm=settings.JWT_ALGORITHM)


def decode_token(token: str) -> dict[str, Any]:
    """Decode and validate JWT token."""
    try:
        return jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[settings.JWT_ALGORITHM],
        )
    except jwt.ExpiredSignatureError:
        raise UnauthorizedException("Token has expired") from None
    except jwt.InvalidTokenError:
        raise UnauthorizedException("Invalid authentication token") from None


class AuthenticatedUserContext:
    def __init__(self, user_id: uuid.UUID, email: str, role: str, org_ids: list[uuid.UUID]):
        self.user_id = user_id
        self.email = email
        self.role = role
        self.org_ids = org_ids


async def get_current_user_token(
    credentials: HTTPAuthorizationCredentials | None = Depends(security_scheme),
) -> dict[str, Any]:
    if not credentials or not credentials.credentials:
        raise UnauthorizedException("Authorization header missing or invalid")
    return decode_token(credentials.credentials)


class TenantContext:
    """Enforces organization-scoped tenancy isolation for provider routes."""

    def __init__(self, required_permission: str | None = None):
        self.required_permission = required_permission

    async def __call__(
        self,
        token_payload: dict[str, Any] = Depends(get_current_user_token),
        x_organization_id: str | None = Header(None, alias="X-Organization-ID"),
        db: AsyncSession = Depends(get_db),
    ) -> uuid.UUID:
        if not x_organization_id:
            raise ForbiddenException("Missing required X-Organization-ID header")

        try:
            target_org_id = uuid.UUID(x_organization_id)
        except ValueError:
            raise ForbiddenException("Invalid X-Organization-ID format") from None

        # In production, check membership in DB; token contains list of allowed orgs
        user_orgs = token_payload.get("org_ids", [])
        user_role = token_payload.get("role", "TRAVELER")

        # Super-admin bypass check
        if user_role == "SUPER_ADMIN":
            return target_org_id

        if str(target_org_id) not in [str(o) for o in user_orgs]:
            raise ForbiddenException(
                f"Unauthorized access: You do not belong to organization '{target_org_id}'"
            )

        return target_org_id
