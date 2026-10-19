import math


def haversine_distance_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Calculate the great-circle distance between two points in km."""
    radius_km = 6371.0  # Earth radius in km

    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = (
        math.sin(dlat / 2) ** 2
        + math.cos(math.radians(lat1))
        * math.cos(math.radians(lat2))
        * math.sin(dlon / 2) ** 2
    )
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return radius_km * c


class SriLankaTransitCalculator:
    """Calculates realistic transit durations across Sri Lankan terrain."""

    # Specific terrain coordinates for Sri Lanka highland zone
    HIGHLAND_BOUNDS = {
        "lat_min": 6.8,
        "lat_max": 7.35,
        "lon_min": 80.5,
        "lon_max": 81.1,
    }

    @classmethod
    def is_in_highlands(cls, lat: float, lon: float) -> bool:
        return (
            cls.HIGHLAND_BOUNDS["lat_min"] <= lat <= cls.HIGHLAND_BOUNDS["lat_max"]
            and cls.HIGHLAND_BOUNDS["lon_min"] <= lon <= cls.HIGHLAND_BOUNDS["lon_max"]
        )

    @classmethod
    def estimate_travel_time_minutes(
        cls,
        origin: tuple[float, float],
        destination: tuple[float, float],
        is_expressway: bool = False,
    ) -> int:
        """
        Returns estimated driving duration in minutes including realistic Sri Lanka road conditions.
        """
        lat1, lon1 = origin
        lat2, lon2 = destination
        straight_km = haversine_distance_km(lat1, lon1, lat2, lon2)

        # Detour factor for winding Sri Lankan roads
        detour_factor = 1.45 if cls.is_in_highlands(lat1, lon1) or cls.is_in_highlands(lat2, lon2) else 1.30
        road_km = straight_km * detour_factor

        if is_expressway:
            avg_speed_kmh = 75.0
        elif cls.is_in_highlands(lat1, lon1) or cls.is_in_highlands(lat2, lon2):
            avg_speed_kmh = 32.0  # Mountain winding roads (Kandy, Nuwara Eliya, Hatton)
        elif straight_km < 15:
            avg_speed_kmh = 22.0  # Urban / congested town traffic
        else:
            avg_speed_kmh = 45.0  # Standard A/B arterial roads

        driving_minutes = int((road_km / avg_speed_kmh) * 60)
        return max(driving_minutes, 15)  # Minimum 15 minutes for any inter-stop transfer
