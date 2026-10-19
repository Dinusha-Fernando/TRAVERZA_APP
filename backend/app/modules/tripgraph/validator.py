from datetime import datetime

from app.modules.tripgraph.schemas import (
    DependencyEdgeValidationInput,
    HardError,
    ItineraryItemValidationInput,
    ValidationResult,
    WarningItem,
)
from app.modules.tripgraph.transit import SriLankaTransitCalculator


class TripGraphValidator:
    """Deterministic validation service for TRAVERZA itineraries."""

    @classmethod
    def validate_itinerary(
        cls,
        items: list[ItineraryItemValidationInput],
        edges: list[DependencyEdgeValidationInput],
    ) -> ValidationResult:
        hard_errors: list[HardError] = []
        warnings: list[WarningItem] = []

        item_map = {item.id: item for item in items}

        # Group items by day
        day_groups = {}
        for item in items:
            day_groups.setdefault(item.day_number, []).append(item)

        # 1. Per-item validation & intra-day ordering
        for day_num, day_items in day_groups.items():
            # Sort items by start time
            sorted_items = sorted(day_items, key=lambda x: x.start_time)

            for i, item in enumerate(sorted_items):
                # Check valid time range
                if item.start_time >= item.end_time:
                    hard_errors.append(
                        HardError(
                            code="INVALID_TIME_RANGE",
                            message=f"Item '{item.title}' has start time ({item.start_time}) after or equal to end time ({item.end_time})",
                            affected_item_ids=[item.id],
                        )
                    )

                # Check opening windows if specified
                if item.opening_time and item.start_time < item.opening_time:
                    hard_errors.append(
                        HardError(
                            code="OUTSIDE_OPENING_HOURS",
                            message=f"'{item.title}' starts at {item.start_time}, but venue opens at {item.opening_time}",
                            affected_item_ids=[item.id],
                        )
                    )
                if item.closing_time and item.end_time > item.closing_time:
                    hard_errors.append(
                        HardError(
                            code="OUTSIDE_CLOSING_HOURS",
                            message=f"'{item.title}' finishes at {item.end_time}, but venue closes at {item.closing_time}",
                            affected_item_ids=[item.id],
                        )
                    )

                # Check manual availability warning
                if not item.provider_confirmed:
                    warnings.append(
                        WarningItem(
                            code="UNCONFIRMED_SUPPLIER",
                            message=f"'{item.title}' is currently unconfirmed by provider. Requires request-to-confirm.",
                            affected_item_ids=[item.id],
                            source="CATALOGUE_RULE",
                        )
                    )

                # Check overlap and transit buffer with consecutive item
                if i < len(sorted_items) - 1:
                    next_item = sorted_items[i + 1]

                    # Check hard overlap
                    if item.end_time > next_item.start_time and item.is_fixed_time and next_item.is_fixed_time:
                        hard_errors.append(
                            HardError(
                                code="SCHEDULE_OVERLAP",
                                message=f"Overlap on Day {day_num}: '{item.title}' ends at {item.end_time}, which clashes with '{next_item.title}' starting at {next_item.start_time}",
                                affected_item_ids=[item.id, next_item.id],
                            )
                        )
                        continue

                    # Calculate transit requirement
                    est_transit_minutes = SriLankaTransitCalculator.estimate_travel_time_minutes(
                        (item.latitude, item.longitude),
                        (next_item.latitude, next_item.longitude),
                    )

                    # Available gap in minutes
                    dt_current_end = datetime.combine(datetime.min, item.end_time)
                    dt_next_start = datetime.combine(datetime.min, next_item.start_time)
                    available_gap_minutes = int((dt_next_start - dt_current_end).total_seconds() / 60)

                    if available_gap_minutes < est_transit_minutes:
                        hard_errors.append(
                            HardError(
                                code="INSUFFICIENT_TRANSIT_TIME",
                                message=(
                                    f"Insufficient travel buffer between '{item.title}' and '{next_item.title}'. "
                                    f"Estimated drive is {est_transit_minutes} mins, but only {available_gap_minutes} mins scheduled."
                                ),
                                affected_item_ids=[item.id, next_item.id],
                                details={
                                    "estimated_transit_minutes": est_transit_minutes,
                                    "available_gap_minutes": available_gap_minutes,
                                },
                            )
                        )
                    elif available_gap_minutes < est_transit_minutes + 15:
                        warnings.append(
                            WarningItem(
                                code="TIGHT_TRANSIT_BUFFER",
                                message=(
                                    f"Tight transit window between '{item.title}' and '{next_item.title}'. "
                                    f"Buffer is only {available_gap_minutes - est_transit_minutes} mins above estimated drive."
                                ),
                                affected_item_ids=[item.id, next_item.id],
                            )
                        )

        # 2. Dependency Edge Validation
        for edge in edges:
            src = item_map.get(edge.source_item_id)
            tgt = item_map.get(edge.target_item_id)
            if not src or not tgt:
                continue

            if src.day_number > tgt.day_number:
                hard_errors.append(
                    HardError(
                        code="INVALID_DEPENDENCY_SEQUENCE",
                        message=f"Dependency error: '{src.title}' on Day {src.day_number} must precede '{tgt.title}' on Day {tgt.day_number}",
                        affected_item_ids=[src.id, tgt.id],
                    )
                )

        is_valid = len(hard_errors) == 0
        summary = (
            f"Validation passed with {len(warnings)} advisory warning(s)."
            if is_valid
            else f"Validation failed with {len(hard_errors)} hard error(s) and {len(warnings)} warning(s)."
        )

        return ValidationResult(
            is_valid=is_valid,
            hard_errors=hard_errors,
            warnings=warnings,
            summary=summary,
        )
