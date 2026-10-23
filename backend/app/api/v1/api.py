from fastapi import APIRouter

from app.modules.admin.router import router as admin_router
from app.modules.atlas.router import router as atlas_router
from app.modules.audit.router import router as audit_router
from app.modules.autopilot.router import router as autopilot_router
from app.modules.bookings.router import router as bookings_router
from app.modules.catalogue.router import router as catalogue_router
from app.modules.community.router import router as community_router
from app.modules.identity.router import router as identity_router
from app.modules.messenger.router import router as messenger_router
from app.modules.notifications.router import router as notifications_router
from app.modules.packages.router import router as packages_router
from app.modules.payments.router import router as payments_router
from app.modules.support.router import router as support_router
from app.modules.trips.router import router as trips_router

api_v1_router = APIRouter()

api_v1_router.include_router(admin_router)
api_v1_router.include_router(identity_router)
api_v1_router.include_router(catalogue_router)
api_v1_router.include_router(packages_router)
api_v1_router.include_router(trips_router)
api_v1_router.include_router(bookings_router)
api_v1_router.include_router(payments_router)
api_v1_router.include_router(support_router)
api_v1_router.include_router(audit_router)
api_v1_router.include_router(notifications_router)
api_v1_router.include_router(autopilot_router)
api_v1_router.include_router(atlas_router)
api_v1_router.include_router(community_router)
api_v1_router.include_router(messenger_router)


