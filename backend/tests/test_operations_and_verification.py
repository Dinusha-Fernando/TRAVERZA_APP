import uuid

import pytest
from httpx import ASGITransport, AsyncClient

from app.core.security import create_access_token
from app.main import app
from app.modules.identity.models import Organization, ProviderDocument


@pytest.mark.asyncio
async def test_provider_document_upload_and_admin_verification(test_db):
    """
    Gate 1: Provider Document Upload & SLTDA Verification Gate.
    Provider submits documents -> Admin inspects and approves -> Status transitions.
    """
    admin_id = uuid.uuid4()
    admin_token = create_access_token(
        subject=str(admin_id),
        extra_claims={"email": "admin@traverza.lk", "role": "SUPER_ADMIN", "org_ids": []},
    )

    org = Organization(
        name="Lanka Chauffeurs (Pvt) Ltd",
        legal_name="Lanka Chauffeur Fleet Operations Ltd",
        business_reg_no="PV-99102",
        sltda_license_no="SLTDA/CG/2026/999",
        category="TRANSPORT",
        is_verified=False,
        contact_email="dispatch@lankachauffeurs.lk",
        contact_phone="+94770001122",
    )
    test_db.add(org)
    await test_db.commit()
    await test_db.refresh(org)

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # 1. Provider uploads SLTDA Tourism License
        upload_res = await client.post(
            f"/api/v1/auth/provider/organizations/{org.id}/documents",
            headers={"Authorization": f"Bearer {admin_token}"},
            json={
                "document_type": "SLTDA_TOURISM_LICENSE",
                "document_number": "SLTDA/CG/2026/999",
                "file_name": "sltda_license_2026.pdf",
                "file_url": "https://storage.traverza.lk/verified-docs/chauffeur-999.pdf",
                "expiry_date": "2027-12-31",
            },
        )
        assert upload_res.status_code == 201
        doc_data = upload_res.json()
        assert doc_data["status"] == "PENDING"
        assert doc_data["document_number"] == "SLTDA/CG/2026/999"

        # 2. Admin inspects and approves the organization
        verify_res = await client.post(
            f"/api/v1/auth/admin/organizations/{org.id}/verify",
            headers={"Authorization": f"Bearer {admin_token}"},
            json={
                "decision": "APPROVE",
                "reason": "SLTDA active registry match confirmed",
                "sltda_license_verified": True,
            },
        )
        assert verify_res.status_code == 200
        org_data = verify_res.json()
        assert org_data["is_verified"] is True

        # 3. Check document status transitioned to APPROVED
        doc = await test_db.get(ProviderDocument, uuid.UUID(doc_data["id"]))
        assert doc.status == "APPROVED"
        assert doc.reviewer_notes == "SLTDA active registry match confirmed"


@pytest.mark.asyncio
async def test_support_exception_desk_lifecycle(test_db):
    """
    Gate 4: Operations Exception Resolution.
    Critical incidents must have tracked states and audited resolution notes.
    """
    user_id = uuid.uuid4()
    token = create_access_token(
        subject=str(user_id),
        extra_claims={"email": "ops@traverza.lk", "role": "TRIP_OPS", "org_ids": []},
    )

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # Create an exception case
        create_res = await client.post(
            "/api/v1/support/cases",
            headers={"Authorization": f"Bearer {token}"},
            json={
                "category": "MISSED_PICKUP",
                "severity": "CRITICAL",
                "summary": "Driver delayed due to traffic on A1",
                "description": "Passenger waiting at Katunayake arrival terminal gate 4",
            },
        )
        assert create_res.status_code == 201
        case_data = create_res.json()
        assert case_data["status"] == "OPEN"
        case_id = case_data["id"]

        # Resolve the exception case
        resolve_res = await client.patch(
            f"/api/v1/support/cases/{case_id}/resolve",
            headers={"Authorization": f"Bearer {token}"},
            json={
                "resolution_notes": "Backup driver dispatched from nearby depot; traveller accommodated in VIP lounge with refreshment voucher.",
                "status": "RESOLVED",
            },
        )
        assert resolve_res.status_code == 200
        resolved_data = resolve_res.json()
        assert resolved_data["status"] == "RESOLVED"
        assert "Backup driver dispatched" in resolved_data["resolution_notes"]
