import uuid
from datetime import time
import pytest
from app.modules.tripgraph.schemas import (
    DependencyEdgeValidationInput,
    ItineraryItemValidationInput,
)
from app.modules.tripgraph.validator import TripGraphValidator


def test_valid_itinerary_passes_with_warnings():
    item1_id = uuid.uuid4()
    item2_id = uuid.uuid4()

    # Day 1: Colombo Airport arrival at 09:00, departure to hotel at 10:30 (adequate gap)
    items = [
        ItineraryItemValidationInput(
            id=item1_id,
            day_number=1,
            title="CMB Airport Flight Arrival",
            start_time=time(9, 0),
            end_time=time(10, 0),
            latitude=7.1808,
            longitude=79.8841,
            category="FLIGHT",
            is_fixed_time=True,
            provider_confirmed=True,
        ),
        ItineraryItemValidationInput(
            id=item2_id,
            day_number=1,
            title="Chauffeur Transfer to Negombo Hotel",
            start_time=time(10, 30),
            end_time=time(11, 30),
            latitude=7.2008,
            longitude=79.8736,
            category="TRANSFER",
            is_fixed_time=True,
            provider_confirmed=False,  # Unconfirmed provider triggers warning
        ),
    ]

    edges = [
        DependencyEdgeValidationInput(
            source_item_id=item1_id,
            target_item_id=item2_id,
            dependency_type="FLIGHT_ARRIVAL_TO_TRANSFER",
            min_buffer_minutes=30,
        )
    ]

    result = TripGraphValidator.validate_itinerary(items, edges)
    assert result.is_valid is True
    assert len(result.hard_errors) == 0
    # Must have warning for unconfirmed provider
    assert any(w.code == "UNCONFIRMED_SUPPLIER" for w in result.warnings)


def test_direct_schedule_overlap_detected():
    item1_id = uuid.uuid4()
    item2_id = uuid.uuid4()

    # Two overlapping fixed-time activities on Day 2 in Kandy
    items = [
        ItineraryItemValidationInput(
            id=item1_id,
            day_number=2,
            title="Temple of the Tooth Relic Guided Tour",
            start_time=time(9, 30),
            end_time=time(11, 30),
            latitude=7.2936,
            longitude=80.6413,
            category="ACTIVITY",
            is_fixed_time=True,
            provider_confirmed=True,
        ),
        ItineraryItemValidationInput(
            id=item2_id,
            day_number=2,
            title="Peradeniya Botanical Gardens Walk",
            start_time=time(11, 0),  # Overlaps by 30 mins!
            end_time=time(13, 0),
            latitude=7.2680,
            longitude=80.5966,
            category="ACTIVITY",
            is_fixed_time=True,
            provider_confirmed=True,
        ),
    ]

    result = TripGraphValidator.validate_itinerary(items, [])
    assert result.is_valid is False
    assert any(e.code == "SCHEDULE_OVERLAP" for e in result.hard_errors)


def test_insufficient_transit_time_in_highlands():
    item1_id = uuid.uuid4()
    item2_id = uuid.uuid4()

    # Kandy (lat 7.29, lon 80.64) to Nuwara Eliya (lat 6.95, lon 80.78):
    # Winding mountain route ~75 km, takes ~2.5 to 3 hours in reality.
    # Scheduled with only 45 minutes between end of Kandy and start of Nuwara Eliya
    items = [
        ItineraryItemValidationInput(
            id=item1_id,
            day_number=3,
            title="Kandy Cultural Morning",
            start_time=time(8, 0),
            end_time=time(10, 0),
            latitude=7.2936,
            longitude=80.6413,
            category="ACTIVITY",
            is_fixed_time=True,
            provider_confirmed=True,
        ),
        ItineraryItemValidationInput(
            id=item2_id,
            day_number=3,
            title="Nuwara Eliya Tea Factory Tour",
            start_time=time(10, 45),  # Only 45 mins after Kandy!
            end_time=time(12, 30),
            latitude=6.9497,
            longitude=80.7891,
            category="ACTIVITY",
            is_fixed_time=True,
            provider_confirmed=True,
        ),
    ]

    result = TripGraphValidator.validate_itinerary(items, [])
    assert result.is_valid is False
    assert any(e.code == "INSUFFICIENT_TRANSIT_TIME" for e in result.hard_errors)


def test_opening_hours_violation_detected():
    item_id = uuid.uuid4()
    items = [
        ItineraryItemValidationInput(
            id=item_id,
            day_number=1,
            title="Museum Early Entry",
            start_time=time(7, 0),
            end_time=time(9, 0),
            latitude=7.0,
            longitude=80.0,
            category="ACTIVITY",
            is_fixed_time=True,
            provider_confirmed=True,
            opening_time=time(8, 30),  # Opens at 8:30, scheduled at 7:00
            closing_time=time(17, 0),
        )
    ]

    result = TripGraphValidator.validate_itinerary(items, [])
    assert result.is_valid is False
    assert any(e.code == "OUTSIDE_OPENING_HOURS" for e in result.hard_errors)
