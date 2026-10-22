class JourneyStatusData {
  final String tripId;
  final String title;
  final int currentDay;
  final int totalDays;
  final String corridor;
  final String derivedStatus;
  final bool isHotelConfirmed;
  final DateTime lastUpdated;

  const JourneyStatusData({
    required this.tripId,
    required this.title,
    required this.currentDay,
    required this.totalDays,
    required this.corridor,
    required this.derivedStatus,
    required this.isHotelConfirmed,
    required this.lastUpdated,
  });
}

enum NextActionUrgency { info, medium, high }

class NextActionData {
  final String title;
  final String description;
  final String deadlineText;
  final int remainingMinutes;
  final NextActionUrgency urgency;
  final String actionLabel;

  const NextActionData({
    required this.title,
    required this.description,
    required this.deadlineText,
    required this.remainingMinutes,
    required this.urgency,
    required this.actionLabel,
  });
}

class TripHealthData {
  final int scorePercentage;
  final String summary;
  final List<String> indicators;
  final bool hasActiveDisruptions;

  const TripHealthData({
    required this.scorePercentage,
    required this.summary,
    required this.indicators,
    required this.hasActiveDisruptions,
  });
}

enum StopCategory { transfer, stay, activity, guide }

class TimelineSegmentData {
  final String timeRange;
  final String title;
  final String location;
  final StopCategory category;
  final String provider;
  final String status;
  final int bufferMinutes;
  final double latitude;
  final double longitude;
  final String notes;

  const TimelineSegmentData({
    required this.timeRange,
    required this.title,
    required this.location,
    required this.category,
    required this.provider,
    required this.status,
    required this.bufferMinutes,
    required this.latitude,
    required this.longitude,
    required this.notes,
  });
}

class BudgetBreakdownData {
  final int committedLKR;
  final int paidLKR;
  final int pendingLKR;
  final int estimatedOnSiteLKR;
  final String currency;
  final String exchangeRateTimestamp;

  const BudgetBreakdownData({
    required this.committedLKR,
    required this.paidLKR,
    required this.pendingLKR,
    required this.estimatedOnSiteLKR,
    this.currency = 'LKR',
    this.exchangeRateTimestamp = 'Verified 22 Oct 2026',
  });

  int get totalSpendLKR => committedLKR + estimatedOnSiteLKR;
}

enum AutopilotSeverity { medium, high, critical }
enum AutopilotStatus { pendingAuthorization, approved, declined }

class AutopilotIncidentData {
  final String id;
  final String tripId;
  final String eventType;
  final String sourceFeed;
  final String observedAt;
  final AutopilotSeverity severity;
  final String impactAnalysis;
  final String proposedResolution;
  final int costDeltaLKR;
  final int timingDeltaMinutes;
  final String? backupProvider;
  final AutopilotStatus status;
  final String tripGraphFeasibility;
  final DateTime timestamp;

  const AutopilotIncidentData({
    required this.id,
    required this.tripId,
    required this.eventType,
    required this.sourceFeed,
    required this.observedAt,
    required this.severity,
    required this.impactAnalysis,
    required this.proposedResolution,
    required this.costDeltaLKR,
    required this.timingDeltaMinutes,
    this.backupProvider,
    required this.status,
    required this.tripGraphFeasibility,
    required this.timestamp,
  });

  AutopilotIncidentData copyWith({
    String? id,
    String? tripId,
    String? eventType,
    String? sourceFeed,
    String? observedAt,
    AutopilotSeverity? severity,
    String? impactAnalysis,
    String? proposedResolution,
    int? costDeltaLKR,
    int? timingDeltaMinutes,
    String? backupProvider,
    AutopilotStatus? status,
    String? tripGraphFeasibility,
    DateTime? timestamp,
  }) {
    return AutopilotIncidentData(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      eventType: eventType ?? this.eventType,
      sourceFeed: sourceFeed ?? this.sourceFeed,
      observedAt: observedAt ?? this.observedAt,
      severity: severity ?? this.severity,
      impactAnalysis: impactAnalysis ?? this.impactAnalysis,
      proposedResolution: proposedResolution ?? this.proposedResolution,
      costDeltaLKR: costDeltaLKR ?? this.costDeltaLKR,
      timingDeltaMinutes: timingDeltaMinutes ?? this.timingDeltaMinutes,
      backupProvider: backupProvider ?? this.backupProvider,
      status: status ?? this.status,
      tripGraphFeasibility: tripGraphFeasibility ?? this.tripGraphFeasibility,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class DigitalVoucherData {
  final String voucherCode;
  final String bookingRef;
  final String serviceTitle;
  final String providerName;
  final String sltdaLicense;
  final String checkInTime;
  final String securityHash;
  final bool isOfflineCached;

  const DigitalVoucherData({
    required this.voucherCode,
    required this.bookingRef,
    required this.serviceTitle,
    required this.providerName,
    required this.sltdaLicense,
    required this.checkInTime,
    required this.securityHash,
    this.isOfflineCached = true,
  });
}
