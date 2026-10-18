from fastapi import APIRouter

from app.modules.bookings.router import router as bookings_router
from app.modules.catalogue.router import router as catalogue_router
from app.modules.identity.router import router as identity_router
from app.modules.payments.router import router as payments_router
from app.modules.trips.router import router as trips_router

api_v1_router = APIRouter()

api_v1_router.include_router(identity_router)
api_v1_router.include_router(catalogue_router)
api_v1_router.include_router(trips_router)
api_v1_router.include_router(bookings_router)
api_v1_router.include_router(payments_router)
