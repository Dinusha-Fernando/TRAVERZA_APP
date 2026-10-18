from typing import Any, Dict, Optional
from fastapi import Request, status
from fastapi.responses import JSONResponse
import uuid


class TraverzaException(Exception):
    """Base domain exception for TRAVERZA."""

    def __init__(
        self,
        code: str,
        message: str,
        status_code: int = status.HTTP_400_BAD_REQUEST,
        details: Optional[Dict[str, Any]] = None,
    ):
        self.code = code
        self.message = message
        self.status_code = status_code
        self.details = details or {}
        super().__init__(message)


class UnauthorizedException(TraverzaException):
    def __init__(self, message: str = "Authentication required"):
        super().__init__(
            code="UNAUTHORIZED",
            message=message,
            status_code=status.HTTP_401_UNAUTHORIZED,
        )


class ForbiddenException(TraverzaException):
    def __init__(self, message: str = "Access denied: insufficient permissions or tenant mismatch"):
        super().__init__(
            code="FORBIDDEN",
            message=message,
            status_code=status.HTTP_403_FORBIDDEN,
        )


class NotFoundException(TraverzaException):
    def __init__(self, resource: str, identifier: Any):
        super().__init__(
            code="NOT_FOUND",
            message=f"{resource} with id '{identifier}' was not found",
            status_code=status.HTTP_404_NOT_FOUND,
            details={"resource": resource, "identifier": str(identifier)},
        )


class QuoteExpiredException(TraverzaException):
    def __init__(self, quote_id: str):
        super().__init__(
            code="QUOTE_EXPIRED",
            message="This quotation offer has expired. Please request an updated quote.",
            status_code=status.HTTP_400_BAD_REQUEST,
            details={"quote_id": quote_id},
        )


class DependencyConflictException(TraverzaException):
    def __init__(self, message: str, conflicts: Dict[str, Any]):
        super().__init__(
            code="DEPENDENCY_CONFLICT",
            message=message,
            status_code=status.HTTP_409_CONFLICT,
            details=conflicts,
        )


async def traverza_exception_handler(request: Request, exc: TraverzaException) -> JSONResponse:
    request_id = getattr(request.state, "request_id", str(uuid.uuid4()))
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "error": {
                "code": exc.code,
                "message": exc.message,
                "request_id": request_id,
                "details": exc.details,
            }
        },
    )
