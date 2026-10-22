'use client';

import { useState } from 'react';
import Link from 'next/link';

interface ExceptionItem {
  id: string;
  severity: 'CRITICAL' | 'HIGH' | 'MEDIUM';
  category: string;
  tripId: string;
  affectedParties: string;
  impact: string;
  deadlineMinutes: number;
  owner: string;
  status: 'OPEN' | 'INVESTIGATING' | 'RESOLVED';
  resolutionNotes?: string;
}

interface ProviderVerificationItem {
  id: string;
  orgName: string;
  sltdaLicense: string;
  category: string;
  docType: string;
  submittedAt: string;
  status: 'PENDING' | 'APPROVED' | 'REJECTED';
}

interface PackageReviewItem {
  id: string;
  packageTitle: string;
  providerOrg: string;
  type: 'OPERATOR_PACKAGE' | 'ITINERARY_TEMPLATE';
  priceLKR: number;
  corridor: string;
  sltdaLicense: string;
  submittedAt: string;
  status: 'IN_REVIEW' | 'APPROVED' | 'CHANGES_REQUESTED' | 'REJECTED';
}

const INITIAL_PACKAGE_REVIEWS: PackageReviewItem[] = [
  {
    id: 'REV-801',
    packageTitle: '4-Day Heritage & Minneriya Safari Tour',
    providerOrg: 'Wild Ceylon Safaris & Expeditions',
    type: 'OPERATOR_PACKAGE',
    priceLKR: 94000,
    corridor: 'Sigiriya · Polonnaruwa · Minneriya',
    sltdaLicense: 'SLTDA/SQA/2026/108',
    submittedAt: 'Today, 07:45 UTC',
    status: 'IN_REVIEW',
  },
  {
    id: 'REV-802',
    packageTitle: '3-Day Cultural Triangle Signature Escape',
    providerOrg: 'Ceylon Heritage Travel Guild',
    type: 'OPERATOR_PACKAGE',
    priceLKR: 68500,
    corridor: 'Colombo · Sigiriya · Kandy · Nuwara Eliya',
    sltdaLicense: 'SLTDA/SQA/2026/044',
    submittedAt: 'Yesterday, 14:10 UTC',
    status: 'APPROVED',
  },
];

const INITIAL_EXCEPTIONS: ExceptionItem[] = [
  {
    id: 'CASE-401',
    severity: 'CRITICAL',
    category: 'PROVIDER_CANCEL',
    tripId: 'TRIP-LK-2026-8902',
    affectedParties: 'Chauffeur Guide (Fleet #LK-102) & Traveller Smith (AU)',
    impact: 'Pickup at CMB Airport in 3h 15m cancelled due to vehicle breakdown. Affects Day 1 transfer + Sigiriya check-in.',
    deadlineMinutes: 45,
    owner: 'Nimali (Trip Ops)',
    status: 'OPEN',
  },
  {
    id: 'CASE-402',
    severity: 'HIGH',
    category: 'UNCONFIRMED_NEAR_TERM',
    tripId: 'TRIP-LK-2026-9041',
    affectedParties: 'Sigiriya Eco Villa & Traveller Dinusha (UK)',
    impact: 'Provider request unresponded with 1h remaining before 12h quote expiry.',
    deadlineMinutes: 62,
    owner: 'Kamal (Supplier Ops)',
    status: 'INVESTIGATING',
  },
  {
    id: 'CASE-403',
    severity: 'MEDIUM',
    category: 'GATEWAY_MISMATCH',
    tripId: 'TRIP-LK-2026-8744',
    affectedParties: 'PayHere Sandbox / Booking #BK-3391',
    impact: 'Webhook received for LKR 12,500 but invoice indicates LKR 12,000. LKR 500 variance held in suspense account.',
    deadlineMinutes: 180,
    owner: 'Arjun (Finance)',
    status: 'OPEN',
  },
];

const INITIAL_VERIFICATIONS: ProviderVerificationItem[] = [
  {
    id: 'ver-101',
    orgName: 'Ceylon Chauffeurs Guild (Pvt) Ltd',
    sltdaLicense: 'SLTDA/CG/2026/102',
    category: 'TRANSPORT',
    docType: 'Fleet Commercial Permits & Chauffeur Licenses',
    submittedAt: 'Today, 08:30 UTC',
    status: 'APPROVED',
  },
  {
    id: 'ver-102',
    orgName: 'Kandy Heritage Walking Guild',
    sltdaLicense: 'SLTDA/GD/2026/044',
    category: 'GUIDE',
    docType: 'Archaeological Guide Badges (National Level)',
    submittedAt: 'Today, 09:15 UTC',
    status: 'PENDING',
  },
];

interface AutopilotIncidentItem {
  id: string;
  tripId: string;
  eventType: 'FLIGHT_DELAY' | 'DRIVER_CANCEL' | 'WEATHER_DISRUPTION' | 'PROVIDER_TIMEOUT';
  source: string;
  observedAt: string;
  severity: 'CRITICAL' | 'HIGH' | 'MEDIUM';
  impactAssessment: string;
  proposedAction: string;
  costDeltaLKR: number;
  timingDeltaMinutes: number;
  backupProvider?: string;
  status: 'PENDING_AUTHORIZATION' | 'DISPATCHED' | 'REJECTED';
  tripGraphFeasibility: 'FEASIBLE' | 'RECHECK_REQUIRED' | 'INFEASIBLE';
}

const INITIAL_AUTOPILOT_INCIDENTS: AutopilotIncidentItem[] = [
  {
    id: 'AP-INC-901',
    tripId: 'TRIP-LK-2026-8902',
    eventType: 'DRIVER_CANCEL',
    source: 'IoT Vehicle Telemetry & Emergency SOS',
    observedAt: '4 minutes ago',
    severity: 'CRITICAL',
    impactAssessment: 'Chauffeur Van (Fleet #LK-102) transmission breakdown on A1 Highway near Warakapola. 3h 15m remaining until CMB Airport arrival.',
    proposedAction: 'Auto-dispatch verified standby chauffeur from Negombo Fleet Hub. Recalculate CMB pickup with 15m buffer.',
    costDeltaLKR: 0,
    timingDeltaMinutes: 15,
    backupProvider: 'Ceylon Chauffeurs Guild (Fleet #LK-214 · SLTDA/CG/2026/102)',
    status: 'PENDING_AUTHORIZATION',
    tripGraphFeasibility: 'FEASIBLE',
  },
  {
    id: 'AP-INC-902',
    tripId: 'TRIP-LK-2026-8902',
    eventType: 'FLIGHT_DELAY',
    source: 'AviationStack Live Radar (UL-504)',
    observedAt: '16 minutes ago',
    severity: 'HIGH',
    impactAssessment: 'UL-504 delayed by +90m. Landing shifted from 14:30 to 16:00. Sigiriya sunset hike cutoff (17:30) at risk of gate closure.',
    proposedAction: 'Shift airport transfer pickup to 16:30. Reschedule Sigiriya Rock ascent to Day 2 sunrise (06:30) and swap Day 1 evening with Minneriya sunset drive.',
    costDeltaLKR: 0,
    timingDeltaMinutes: 90,
    backupProvider: 'Sigiriya Cultural Guide Guild (SLTDA/GD/2026/044)',
    status: 'PENDING_AUTHORIZATION',
    tripGraphFeasibility: 'FEASIBLE',
  },
  {
    id: 'AP-INC-903',
    tripId: 'TRIP-LK-2026-9041',
    eventType: 'WEATHER_DISRUPTION',
    source: 'Sri Lanka Disaster Management Centre (SL-DMCC)',
    observedAt: '28 minutes ago',
    severity: 'MEDIUM',
    impactAssessment: 'Heavy monsoon rainfall advisory on A5 Highway (Ramboda Pass). Nuwara Eliya mountain pass vehicle speed restricted to 25 km/h.',
    proposedAction: 'Re-route via Hatton/Gampola corridor (+22 km, +35m duration) avoiding active mudslide advisory zone.',
    costDeltaLKR: 3500,
    timingDeltaMinutes: 35,
    status: 'PENDING_AUTHORIZATION',
    tripGraphFeasibility: 'FEASIBLE',
  },
];

interface AtlasContributionItem {
  id: string;
  destinationName: string;
  district: string;
  province: string;
  type: 'NEW_DESTINATION' | 'PRICE_UPDATE' | 'ROAD_ACCESS_ALERT' | 'HOURS_UPDATE';
  contributor: string;
  contributorTrustScore: number;
  submittedAt: string;
  details: string;
  evidence: string;
  status: 'PENDING' | 'APPROVED' | 'REJECTED' | 'NEEDS_EVIDENCE';
}

const INITIAL_ATLAS_CONTRIBUTIONS: AtlasContributionItem[] = [
  {
    id: 'ATLAS-C-101',
    destinationName: "Lipton's Seat Viewpoint & Dambatenne Trail",
    district: 'Badulla',
    province: 'Uva Province',
    type: 'ROAD_ACCESS_ALERT',
    contributor: 'Ranjith Perera (Haputale Local Guide · SLTDA Registered)',
    contributorTrustScore: 98,
    submittedAt: 'Today, 11:20 UTC',
    details: 'Upper road past Dambatenne tea factory undergoing culvert resurfacing. Tuk-tuks and 4WD passable, low-clearance sedans advised to park at lower tea gate and hike 1.5 km.',
    evidence: 'On-site photograph with timestamp & Road Development Authority (RDA) Haputale notice #LK-RDA-2026/89',
    status: 'PENDING',
  },
  {
    id: 'ATLAS-C-102',
    destinationName: 'Kallady Beach Singing Fish Phenomenon Point',
    district: 'Batticaloa',
    province: 'Eastern Province',
    type: 'HOURS_UPDATE',
    contributor: 'Selvamurugan K. (Batticaloa Heritage Society)',
    contributorTrustScore: 94,
    submittedAt: 'Today, 09:40 UTC',
    details: 'Best acoustic resonance occurs between 20:00 - 22:30 during full moon windows (Poya days). Lagoon boatmen operate from Lady Manning Bridge jetty.',
    evidence: 'Batticaloa Municipal Council Tourism Desk publication & local lagoon guild schedule',
    status: 'PENDING',
  },
  {
    id: 'ATLAS-C-103',
    destinationName: 'Nallur Kandaswamy Kovil Morning Puja Timing',
    district: 'Jaffna',
    province: 'Northern Province',
    type: 'HOURS_UPDATE',
    contributor: 'Thulasi V. (Jaffna University Cultural Researcher)',
    contributorTrustScore: 99,
    submittedAt: 'Yesterday, 16:15 UTC',
    details: 'Verified traditional dress etiquette: men must enter upper sanctum bare-chested; footwear prohibited past outer gateway. Morning puja starts at 06:00 sharp.',
    evidence: 'Nallur Devasthanam official notice board & Temple Board 2026 Calendar',
    status: 'APPROVED',
  },
  {
    id: 'ATLAS-C-104',
    destinationName: 'Kalu Diya Pokuna Forest Hermitage',
    district: 'Matale',
    province: 'Central Province',
    type: 'NEW_DESTINATION',
    contributor: 'Dr. Anura Wickramasinghe (Central Cultural Fund)',
    contributorTrustScore: 100,
    submittedAt: 'Yesterday, 13:00 UTC',
    details: 'Uncrowded 9th-century Buddhist monastic ruins situated inside Dambulla forest sanctuary. Ideal contemplative stop 15 mins south of Kandalama.',
    evidence: 'Archaeological Department Monument Registry Ref #AMD-2024-C92',
    status: 'PENDING',
  },
];

interface CommunityReportItem {
  id: string;
  targetType: 'POST' | 'COMMENT' | 'USER';
  reportedItemAuthor: string;
  reporterName: string;
  reason: 'SPAM' | 'HARASSMENT' | 'MISLEADING_ADVICE' | 'SAFETY_CONCERN' | 'FALSE_LOCATION';
  reportedAt: string;
  district: string;
  destination?: string;
  excerpt: string;
  status: 'PENDING' | 'APPROVED_SAFE' | 'FLAGGED' | 'REMOVED';
  moderatorNotes?: string;
}

const INITIAL_COMMUNITY_REPORTS: CommunityReportItem[] = [
  {
    id: 'REP-701',
    targetType: 'POST',
    reportedItemAuthor: 'AdventureTravelGuy_99',
    reporterName: 'Duminda Bandara (Licensed Guide)',
    reason: 'MISLEADING_ADVICE',
    reportedAt: '24 mins ago',
    district: 'Matale',
    destination: 'Knuckles Mountain Range',
    excerpt: 'Claims that Riverston Mini World’s End trail is open for unattended midnight camping without forestry department permits.',
    status: 'PENDING',
  },
  {
    id: 'REP-702',
    targetType: 'COMMENT',
    reportedItemAuthor: 'CheapTours_Colombo',
    reporterName: 'Ayesha De Silva',
    reason: 'SPAM',
    reportedAt: '1h 10m ago',
    district: 'Galle',
    destination: 'Galle Dutch Fort',
    excerpt: 'Repeatedly pasting external WhatsApp phone numbers claiming unverified whale watching discounts.',
    status: 'PENDING',
  },
  {
    id: 'REP-703',
    targetType: 'POST',
    reportedItemAuthor: 'CliffJumper_LK',
    reporterName: 'Ceylon Chauffeurs Guild',
    reason: 'SAFETY_CONCERN',
    reportedAt: '2h 45m ago',
    district: 'Badulla',
    destination: 'Diyaluma Falls',
    excerpt: 'Encouraging tourists to dive from upper rock pools during active monsoon flash-flood warning period.',
    status: 'PENDING',
  },
];

export default function AdminOpsPage() {
  const [exceptions, setExceptions] = useState<ExceptionItem[]>(INITIAL_EXCEPTIONS);
  const [verifications, setVerifications] = useState<ProviderVerificationItem[]>(INITIAL_VERIFICATIONS);
  const [packageReviews, setPackageReviews] = useState<PackageReviewItem[]>(INITIAL_PACKAGE_REVIEWS);
  const [autopilotIncidents, setAutopilotIncidents] = useState<AutopilotIncidentItem[]>(INITIAL_AUTOPILOT_INCIDENTS);
  const [atlasContributions, setAtlasContributions] = useState<AtlasContributionItem[]>(INITIAL_ATLAS_CONTRIBUTIONS);
  const [communityReports, setCommunityReports] = useState<CommunityReportItem[]>(INITIAL_COMMUNITY_REPORTS);
  const [activeCaseId, setActiveCaseId] = useState<string>('CASE-401');
  const [adminTab, setAdminTab] = useState<'exceptions' | 'verification' | 'packages' | 'audit' | 'autopilot' | 'atlas' | 'community'>('exceptions');
  const [resolutionInput, setResolutionInput] = useState('');
  const [notification, setNotification] = useState<string | null>(null);

  const handleCommunityDecision = (id: string, decision: 'APPROVED_SAFE' | 'FLAGGED' | 'REMOVED', note?: string) => {
    setCommunityReports((prev) =>
      prev.map((r) =>
        r.id === id ? { ...r, status: decision, moderatorNotes: note || 'Decision applied by moderator.' } : r
      )
    );
    const msg =
      decision === 'APPROVED_SAFE'
        ? `Report ${id} dismissed. Content approved and restored to public Community Pulse feed.`
        : decision === 'FLAGGED'
        ? `Content ${id} flagged for Safety Review. Distribution limited.`
        : `Content ${id} REMOVED from Community Pulse feed. Audit log updated and author warned.`;
    setNotification(msg);
    setTimeout(() => setNotification(null), 5000);
  };

  const handleAtlasDecision = (id: string, decision: 'APPROVED' | 'REJECTED' | 'NEEDS_EVIDENCE') => {
    setAtlasContributions((prev) =>
      prev.map((item) => (item.id === id ? { ...item, status: decision } : item))
    );
    const msg =
      decision === 'APPROVED'
        ? `Atlas contribution ${id} APPROVED and published across all 25 districts!`
        : decision === 'NEEDS_EVIDENCE'
        ? `Contribution ${id} flagged: field photos/evidence requested from contributor.`
        : `Contribution ${id} rejected and archived.`;
    setNotification(msg);
    setTimeout(() => setNotification(null), 5000);
  };

  const handleAutopilotDecision = (id: string, decision: 'APPROVED' | 'REJECTED') => {
    setAutopilotIncidents((prev) =>
      prev.map((item) =>
        item.id === id
          ? { ...item, status: decision === 'APPROVED' ? 'DISPATCHED' : 'REJECTED' }
          : item
      )
    );
    const msg =
      decision === 'APPROVED'
        ? `Autopilot Proposal ${id} APPROVED! Backup provider dispatched & traveller notified via WhatsApp/SMS.`
        : `Autopilot Proposal ${id} REJECTED. Original itinerary preserved; manual concierge assigned.`;
    setNotification(msg);
    setTimeout(() => setNotification(null), 5000);
  };

  const handlePackageDecision = (id: string, decision: 'APPROVED' | 'CHANGES_REQUESTED' | 'REJECTED' | 'IN_REVIEW') => {
    setPackageReviews((prev) =>
      prev.map((p) => (p.id === id ? { ...p, status: decision } : p))
    );
    const msg =
      decision === 'APPROVED'
        ? `Package ${id} approved & published to traveller marketplace! Immutable snapshot created.`
        : decision === 'CHANGES_REQUESTED'
        ? `Changes requested for package ${id}. Provider notified with audit checklist.`
        : decision === 'IN_REVIEW'
        ? `Package ${id} returned to IN_REVIEW status.`
        : `Package ${id} rejected. Reason logged in regulatory audit trail.`;
    setNotification(msg);
    setTimeout(() => setNotification(null), 5000);
  };

  const activeCase = exceptions.find((c) => c.id === activeCaseId) || exceptions[0];

  const handleResolve = () => {
    if (!resolutionInput.trim()) return;

    setExceptions((prev) =>
      prev.map((c) =>
        c.id === activeCaseId
          ? {
              ...c,
              status: 'RESOLVED',
              resolutionNotes: resolutionInput,
            }
          : c
      )
    );

    setNotification(`Case ${activeCaseId} resolved. Audited notes recorded. SLTDA grievance queue updated.`);
    setResolutionInput('');
    setTimeout(() => setNotification(null), 5000);
  };

  const handleVerifyProvider = (id: string, decision: 'APPROVED' | 'REJECTED') => {
    setVerifications((prev) =>
      prev.map((v) => (v.id === id ? { ...v, status: decision } : v))
    );

    setNotification(
      decision === 'APPROVED'
        ? `Provider verification ${id} approved! Organization marked as SLTDA Verified.`
        : `Provider verification ${id} rejected with reason logged.`
    );
    setTimeout(() => setNotification(null), 5000);
  };

  return (
    <div style={{ maxWidth: '1280px', margin: '0 auto', padding: '40px 24px' }}>
      {/* Header */}
      <div
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          marginBottom: '32px',
          flexWrap: 'wrap',
          gap: '20px',
          background: 'linear-gradient(135deg, rgba(16, 42, 67, 0.75) 0%, rgba(11, 110, 142, 0.2) 100%)',
          padding: '24px 28px',
          borderRadius: 'var(--radius-md)',
          border: '1px solid rgba(27, 166, 166, 0.3)',
          boxShadow: '0 8px 32px rgba(0, 0, 0, 0.25)',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '20px' }}>
          <img
            src="/traverza-logo.jpg"
            alt="TRAVERZA Logo"
            style={{
              width: '64px',
              height: '64px',
              borderRadius: '16px',
              objectFit: 'cover',
              boxShadow: '0 8px 24px rgba(11, 110, 142, 0.5)',
              border: '2px solid rgba(27, 166, 166, 0.45)',
            }}
          />
          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
              <h1 style={{ fontSize: '2.0rem', margin: 0 }}>TRAVERZA Operations & Exception Desk</h1>
              <span className="badge badge-ruby">MFA Authenticated</span>
            </div>
            <p style={{ color: 'var(--text-secondary)', marginTop: '6px', marginBottom: 0, fontSize: '0.92rem' }}>
              Priority Incident Resolution • Tenant Audited • SLTDA Grievance Compliance (Sections 15 & 16)
            </p>
          </div>
        </div>

        <div style={{ display: 'flex', gap: '12px' }}>
          <Link href="/" className="btn btn-secondary">
            Live Explorer
          </Link>
          <button className="btn btn-primary">Export Regulatory Incident Log</button>
        </div>
      </div>

      {/* Tabs */}
      <div style={{ display: 'flex', gap: '12px', marginBottom: '24px', flexWrap: 'wrap' }}>
        <button
          onClick={() => setAdminTab('exceptions')}
          className={`btn ${adminTab === 'exceptions' ? 'btn-primary' : 'btn-secondary'}`}
        >
          Urgent Exception Queue ({exceptions.filter((e) => e.status !== 'RESOLVED').length})
        </button>
        <button
          onClick={() => setAdminTab('packages')}
          className={`btn ${adminTab === 'packages' ? 'btn-primary' : 'btn-secondary'}`}
        >
          Package Review Queue ({packageReviews.filter((p) => p.status === 'IN_REVIEW').length})
        </button>
        <button
          onClick={() => setAdminTab('verification')}
          className={`btn ${adminTab === 'verification' ? 'btn-primary' : 'btn-secondary'}`}
        >
          Provider Verification Queue ({verifications.filter((v) => v.status === 'PENDING').length})
        </button>
        <button
          onClick={() => setAdminTab('autopilot')}
          className={`btn ${adminTab === 'autopilot' ? 'btn-primary' : 'btn-secondary'}`}
        >
          Autopilot Disruption Desk ({autopilotIncidents.filter((i) => i.status === 'PENDING_AUTHORIZATION').length})
        </button>
        <button
          onClick={() => setAdminTab('atlas')}
          className={`btn ${adminTab === 'atlas' ? 'btn-primary' : 'btn-secondary'}`}
        >
          🧭 Atlas Curation Desk ({atlasContributions.filter((c) => c.status === 'PENDING').length})
        </button>
        <button
          onClick={() => setAdminTab('community')}
          className={`btn ${adminTab === 'community' ? 'btn-primary' : 'btn-secondary'}`}
        >
          🛡️ Community Moderation Desk ({communityReports.filter((r) => r.status === 'PENDING').length})
        </button>
        <button
          onClick={() => setAdminTab('audit')}
          className={`btn ${adminTab === 'audit' ? 'btn-primary' : 'btn-secondary'}`}
        >
          Immutable Audit Log Stream
        </button>
      </div>

      {/* Notification Toast */}
      {notification && (
        <div
          className="animate-fade-in"
          style={{
            padding: '16px 20px',
            marginBottom: '24px',
            borderRadius: 'var(--radius-sm)',
            background: 'rgba(16, 185, 129, 0.15)',
            border: '1px solid rgba(16, 185, 129, 0.4)',
            color: '#34d399',
            fontSize: '0.92rem',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
          }}
        >
          <span>{notification}</span>
          <button
            onClick={() => setNotification(null)}
            style={{ background: 'none', border: 'none', color: '#fff', cursor: 'pointer' }}
          >
            ✕
          </button>
        </div>
      )}

      {/* Tab 1: Exception Queue */}
      {adminTab === 'exceptions' && (
        <div style={{ display: 'grid', gridTemplateColumns: 'minmax(0, 1fr) 440px', gap: '32px' }}>
          {/* Left Column: Sorted Exception Queue */}
          <div className="glass-panel" style={{ padding: '28px' }}>
            <div
              style={{
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'center',
                marginBottom: '20px',
              }}
            >
              <div>
                <h2 style={{ fontSize: '1.3rem' }}>Exception Queue (Sorted by Urgency)</h2>
                <p style={{ fontSize: '0.82rem', color: 'var(--text-muted)' }}>
                  Rule: Zero silent actions. Exceptions must have named owners and audited outcomes.
                </p>
              </div>
              <span className="badge badge-ruby">
                {exceptions.filter((e) => e.status !== 'RESOLVED').length} Active Incidents
              </span>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              {exceptions.map((exc) => (
                <div
                  key={exc.id}
                  onClick={() => setActiveCaseId(exc.id)}
                  style={{
                    background:
                      activeCaseId === exc.id
                        ? 'rgba(255, 255, 255, 0.06)'
                        : 'rgba(255, 255, 255, 0.02)',
                    border:
                      activeCaseId === exc.id
                        ? '1px solid var(--accent-emerald)'
                        : '1px solid var(--border-glass)',
                    borderRadius: 'var(--radius-sm)',
                    padding: '20px',
                    cursor: 'pointer',
                    transition: 'all var(--transition-fast)',
                  }}
                >
                  <div
                    style={{
                      display: 'flex',
                      justifyContent: 'space-between',
                      alignItems: 'flex-start',
                      marginBottom: '8px',
                    }}
                  >
                    <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                      <span
                        className={`badge ${
                          exc.severity === 'CRITICAL'
                            ? 'badge-ruby'
                            : exc.severity === 'HIGH'
                            ? 'badge-amber'
                            : 'badge-sapphire'
                        }`}
                        style={{ fontSize: '0.72rem' }}
                      >
                        {exc.severity}
                      </span>
                      <strong style={{ fontSize: '1.05rem' }}>{exc.id}</strong>
                    </div>

                    <span
                      className={`badge ${
                        exc.status === 'RESOLVED' ? 'badge-emerald' : 'badge-amber'
                      }`}
                      style={{ fontSize: '0.72rem' }}
                    >
                      {exc.status}
                    </span>
                  </div>

                  <p style={{ fontSize: '0.9rem', color: '#f8fafc', marginBottom: '8px' }}>
                    {exc.impact}
                  </p>

                  <div
                    style={{
                      display: 'flex',
                      justifyContent: 'space-between',
                      fontSize: '0.8rem',
                      color: 'var(--text-muted)',
                      paddingTop: '8px',
                      borderTop: '1px solid rgba(255, 255, 255, 0.05)',
                    }}
                  >
                    <span>Owner: <strong>{exc.owner}</strong></span>
                    <span>SLA Deadline: <strong>{exc.deadlineMinutes}m remaining</strong></span>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Right Column: Case Resolution & Details */}
          <div>
            <div className="glass-panel" style={{ padding: '28px', position: 'sticky', top: '100px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
                <h3 style={{ fontSize: '1.25rem' }}>Incident Action Desk</h3>
                <span className="badge badge-sapphire">{activeCase.id}</span>
              </div>

              <div style={{ display: 'flex', flexDirection: 'column', gap: '14px', fontSize: '0.88rem', marginBottom: '24px' }}>
                <div>
                  <span style={{ color: 'var(--text-muted)', display: 'block', fontSize: '0.78rem' }}>Trip ID</span>
                  <strong style={{ fontFamily: 'monospace', color: 'var(--accent-emerald)' }}>{activeCase.tripId}</strong>
                </div>
                <div>
                  <span style={{ color: 'var(--text-muted)', display: 'block', fontSize: '0.78rem' }}>Affected Parties</span>
                  <strong>{activeCase.affectedParties}</strong>
                </div>
                <div>
                  <span style={{ color: 'var(--text-muted)', display: 'block', fontSize: '0.78rem' }}>Category</span>
                  <span className="badge badge-sapphire" style={{ fontSize: '0.75rem', marginTop: '4px' }}>
                    {activeCase.category}
                  </span>
                </div>
                <div>
                  <span style={{ color: 'var(--text-muted)', display: 'block', fontSize: '0.78rem' }}>Impact Description</span>
                  <p style={{ color: 'var(--text-secondary)', marginTop: '4px', lineHeight: 1.5 }}>
                    {activeCase.impact}
                  </p>
                </div>

                {activeCase.resolutionNotes && (
                  <div
                    style={{
                      padding: '12px',
                      borderRadius: 'var(--radius-sm)',
                      background: 'rgba(16, 185, 129, 0.1)',
                      border: '1px solid rgba(16, 185, 129, 0.3)',
                    }}
                  >
                    <span style={{ color: '#34d399', fontWeight: 600, display: 'block', fontSize: '0.8rem' }}>
                      Resolution Notes Recorded:
                    </span>
                    <p style={{ fontSize: '0.85rem', color: '#f8fafc', marginTop: '4px' }}>
                      {activeCase.resolutionNotes}
                    </p>
                  </div>
                )}
              </div>

              {activeCase.status !== 'RESOLVED' && (
                <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                  <label style={{ fontSize: '0.82rem', color: 'var(--text-secondary)' }}>
                    Mandatory Resolution Action & Operator Notes:
                  </label>
                  <textarea
                    rows={3}
                    placeholder="e.g. Dispatched replacement Prado from Negombo fleet hub. Informed traveller."
                    value={resolutionInput}
                    onChange={(e) => setResolutionInput(e.target.value)}
                    style={{
                      width: '100%',
                      padding: '10px',
                      borderRadius: 'var(--radius-sm)',
                      background: '#070b12',
                      border: '1px solid var(--border-glass)',
                      color: '#fff',
                      fontSize: '0.85rem',
                      resize: 'none',
                    }}
                  />
                  <button
                    onClick={handleResolve}
                    disabled={!resolutionInput.trim()}
                    className="btn btn-primary"
                    style={{ width: '100%', fontSize: '0.9rem' }}
                  >
                    Mark Resolved & Log Audit Entry
                  </button>
                </div>
              )}
            </div>
          </div>
        </div>
      )}

      {/* Tab 2: Provider Verification Queue */}
      {adminTab === 'verification' && (
        <div className="glass-panel" style={{ padding: '32px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
            <div>
              <h2 style={{ fontSize: '1.3rem' }}>Provider Credential Verification Queue</h2>
              <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)' }}>
                Inspect business registrations, vehicle permits, and SLTDA official licenses before publishing listings.
              </p>
            </div>
            <span className="badge badge-emerald">SLTDA Registry Connected</span>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            {verifications.map((item) => (
              <div
                key={item.id}
                style={{
                  padding: '20px',
                  background: 'rgba(255, 255, 255, 0.02)',
                  borderRadius: 'var(--radius-sm)',
                  border: '1px solid var(--border-glass)',
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                }}
              >
                <div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                    <h3 style={{ fontSize: '1.15rem' }}>{item.orgName}</h3>
                    <span className="badge badge-sapphire" style={{ fontSize: '0.72rem' }}>
                      {item.category}
                    </span>
                    <span
                      className={`badge ${
                        item.status === 'APPROVED' ? 'badge-emerald' : 'badge-amber'
                      }`}
                      style={{ fontSize: '0.72rem' }}
                    >
                      {item.status}
                    </span>
                  </div>
                  <div style={{ fontSize: '0.88rem', color: 'var(--text-secondary)', marginTop: '4px' }}>
                    SLTDA Licence: <strong style={{ fontFamily: 'monospace' }}>{item.sltdaLicense}</strong> • Evidence: <strong>{item.docType}</strong>
                  </div>
                  <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)', marginTop: '2px' }}>
                    Submitted: {item.submittedAt}
                  </div>
                </div>

                <div>
                  {item.status === 'PENDING' ? (
                    <div style={{ display: 'flex', gap: '10px' }}>
                      <button
                        onClick={() => handleVerifyProvider(item.id, 'REJECTED')}
                        className="btn btn-secondary"
                        style={{ fontSize: '0.82rem', padding: '6px 14px' }}
                      >
                        Reject
                      </button>
                      <button
                        onClick={() => handleVerifyProvider(item.id, 'APPROVED')}
                        className="btn btn-primary"
                        style={{ fontSize: '0.82rem', padding: '6px 18px' }}
                      >
                        Approve & Verify
                      </button>
                    </div>
                  ) : (
                    <span className="badge badge-emerald">Verified</span>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Tab: Package Review Queue (Spec §3.3 & §10.2) */}
      {adminTab === 'packages' && (
        <div className="glass-panel" style={{ padding: '32px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
            <h2 style={{ fontSize: '1.3rem', margin: 0 }}>Package Review & Publication Queue</h2>
            <span className="badge badge-emerald">SLTDA Section 3 Enforced</span>
          </div>
          <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginBottom: '24px' }}>
            Check provider credentials, route feasibility, pricing transparency and inclusions. Only approved packages appear in traveller search.
          </p>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            {packageReviews.map((item) => (
              <div
                key={item.id}
                style={{
                  padding: '24px',
                  background: 'rgba(255, 255, 255, 0.02)',
                  borderRadius: 'var(--radius-sm)',
                  border: '1px solid var(--border-glass)',
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  flexWrap: 'wrap',
                  gap: '20px',
                }}
              >
                <div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                    <span className="badge badge-sapphire" style={{ fontSize: '0.72rem' }}>
                      {item.type === 'OPERATOR_PACKAGE' ? 'OPERATOR BUNDLE' : 'ITINERARY TEMPLATE'}
                    </span>
                    <span
                      className={`badge ${
                        item.status === 'APPROVED'
                          ? 'badge-emerald'
                          : item.status === 'IN_REVIEW'
                          ? 'badge-amber'
                          : 'badge-ruby'
                      }`}
                      style={{ fontSize: '0.72rem' }}
                    >
                      {item.status}
                    </span>
                    <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>Case #{item.id}</span>
                  </div>
                  <h3 style={{ fontSize: '1.18rem', marginTop: '8px', marginBottom: '4px' }}>{item.packageTitle}</h3>
                  <div style={{ fontSize: '0.88rem', color: 'var(--text-secondary)' }}>
                    Provider: <strong>{item.providerOrg}</strong> • SLTDA: <strong style={{ fontFamily: 'monospace' }}>{item.sltdaLicense}</strong>
                  </div>
                  <div style={{ fontSize: '0.82rem', color: 'var(--text-muted)', marginTop: '2px' }}>
                    Corridor: <strong>{item.corridor}</strong> • Price Basis: <strong>LKR {item.priceLKR.toLocaleString()} / person</strong> • Submitted: {item.submittedAt}
                  </div>
                </div>

                <div>
                  {item.status === 'IN_REVIEW' ? (
                    <div style={{ display: 'flex', gap: '10px' }}>
                      <button
                        onClick={() => handlePackageDecision(item.id, 'CHANGES_REQUESTED')}
                        className="btn btn-secondary"
                        style={{ fontSize: '0.82rem', padding: '8px 14px' }}
                      >
                        Request Changes
                      </button>
                      <button
                        onClick={() => handlePackageDecision(item.id, 'REJECTED')}
                        className="btn btn-secondary"
                        style={{ fontSize: '0.82rem', padding: '8px 14px', borderColor: 'var(--accent-amber)' }}
                      >
                        Reject
                      </button>
                      <button
                        onClick={() => handlePackageDecision(item.id, 'APPROVED')}
                        className="btn btn-primary"
                        style={{ fontSize: '0.82rem', padding: '8px 18px' }}
                      >
                        Approve & Publish
                      </button>
                    </div>
                  ) : (
                    <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                      <span className="badge badge-emerald">Live on Traveller Marketplace</span>
                      <button
                        onClick={() => handlePackageDecision(item.id, 'IN_REVIEW')}
                        className="btn btn-secondary"
                        style={{ fontSize: '0.75rem', padding: '4px 10px' }}
                      >
                        Reopen Review
                      </button>
                    </div>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Tab: Autopilot Disruption & Fleet Dispatch Desk (TRAVERZA 2.0 §3 & §6) */}
      {adminTab === 'autopilot' && (
        <div className="glass-panel" style={{ padding: '32px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px', flexWrap: 'wrap', gap: '16px' }}>
            <div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <h2 style={{ fontSize: '1.35rem', margin: 0 }}>TRAVERZA 2.0 Autopilot Fleet Dispatch & Recovery Desk</h2>
                <span className="badge badge-sapphire">Deterministic TripGraph 2.0</span>
              </div>
              <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginTop: '6px', marginBottom: 0 }}>
                Real-time incident ingestion (flight radars, IoT telematics, met radar) • Autonomous constraint evaluation • Mandatory human authorization gate.
              </p>
            </div>
            <div style={{ display: 'flex', gap: '8px' }}>
              <span className="badge badge-emerald">6-Step Loop: Active</span>
              <span className="badge badge-amber">SLA Escalation: 45m</span>
            </div>
          </div>

          {/* Quick Metrics Bar */}
          <div
            style={{
              display: 'grid',
              gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))',
              gap: '16px',
              margin: '24px 0',
            }}
          >
            <div style={{ padding: '16px', background: 'rgba(255, 255, 255, 0.03)', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border-glass)' }}>
              <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)', textTransform: 'uppercase' }}>Active Disruptions</div>
              <div style={{ fontSize: '1.5rem', fontWeight: 700, color: '#f8fafc', marginTop: '4px' }}>{autopilotIncidents.length} Events</div>
            </div>
            <div style={{ padding: '16px', background: 'rgba(239, 68, 68, 0.08)', borderRadius: 'var(--radius-sm)', border: '1px solid rgba(239, 68, 68, 0.25)' }}>
              <div style={{ fontSize: '0.75rem', color: '#fca5a5', textTransform: 'uppercase' }}>Pending Dispatch Approval</div>
              <div style={{ fontSize: '1.5rem', fontWeight: 700, color: '#f87171', marginTop: '4px' }}>
                {autopilotIncidents.filter((i) => i.status === 'PENDING_AUTHORIZATION').length} Pending
              </div>
            </div>
            <div style={{ padding: '16px', background: 'rgba(16, 185, 129, 0.08)', borderRadius: 'var(--radius-sm)', border: '1px solid rgba(16, 185, 129, 0.25)' }}>
              <div style={{ fontSize: '0.75rem', color: '#6ee7b7', textTransform: 'uppercase' }}>Resolved & Rescheduled</div>
              <div style={{ fontSize: '1.5rem', fontWeight: 700, color: '#34d399', marginTop: '4px' }}>
                {autopilotIncidents.filter((i) => i.status === 'DISPATCHED').length} Dispatched
              </div>
            </div>
          </div>

          {/* Incident Stream Cards */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            {autopilotIncidents.map((incident) => (
              <div
                key={incident.id}
                style={{
                  padding: '24px',
                  background: incident.status === 'PENDING_AUTHORIZATION' ? 'rgba(255, 255, 255, 0.03)' : 'rgba(255, 255, 255, 0.01)',
                  borderRadius: 'var(--radius-sm)',
                  border: incident.status === 'PENDING_AUTHORIZATION' ? '1px solid rgba(239, 68, 68, 0.35)' : '1px solid var(--border-glass)',
                  display: 'flex',
                  flexDirection: 'column',
                  gap: '14px',
                }}
              >
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '12px' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                    <span
                      className={`badge ${
                        incident.severity === 'CRITICAL' ? 'badge-ruby' : incident.severity === 'HIGH' ? 'badge-amber' : 'badge-sapphire'
                      }`}
                      style={{ fontSize: '0.75rem' }}
                    >
                      {incident.severity} · {incident.eventType.replace('_', ' ')}
                    </span>
                    <span style={{ fontFamily: 'monospace', fontSize: '0.85rem', color: 'var(--text-muted)' }}>
                      #{incident.id}
                    </span>
                    <span style={{ fontSize: '0.82rem', color: 'var(--accent-sapphire)' }}>
                      Trip: <strong>{incident.tripId}</strong>
                    </span>
                  </div>

                  <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                    <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>
                      📡 Provenance: <strong>{incident.source}</strong> ({incident.observedAt})
                    </span>
                    <span
                      className={`badge ${
                        incident.status === 'DISPATCHED'
                          ? 'badge-emerald'
                          : incident.status === 'REJECTED'
                          ? 'badge-ruby'
                          : 'badge-amber'
                      }`}
                    >
                      {incident.status.replace('_', ' ')}
                    </span>
                  </div>
                </div>

                {/* Impact Analysis */}
                <div style={{ background: 'rgba(0, 0, 0, 0.25)', padding: '14px 18px', borderRadius: 'var(--radius-sm)', border: '1px solid rgba(255, 255, 255, 0.04)' }}>
                  <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)', marginBottom: '4px', textTransform: 'uppercase', letterSpacing: '0.04em' }}>
                    Assessed Disruption Impact
                  </div>
                  <div style={{ fontSize: '0.92rem', color: '#f1f5f9', lineHeight: 1.5 }}>
                    {incident.impactAssessment}
                  </div>
                </div>

                {/* Proposed Recovery Action with Deliberate Plan & Cost Delta */}
                <div style={{ background: 'rgba(11, 110, 142, 0.12)', padding: '16px 20px', borderRadius: 'var(--radius-sm)', border: '1px solid rgba(27, 166, 166, 0.3)' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px', flexWrap: 'wrap', gap: '10px' }}>
                    <div style={{ fontSize: '0.8rem', color: 'var(--accent-teal)', textTransform: 'uppercase', letterSpacing: '0.04em', fontWeight: 600 }}>
                      ⚡ Autopilot Proposed Recovery Itinerary
                    </div>
                    <div style={{ display: 'flex', gap: '12px', fontSize: '0.82rem' }}>
                      <span style={{ color: 'var(--accent-emerald)', fontWeight: 600 }}>
                        Cost Delta: {incident.costDeltaLKR === 0 ? 'LKR 0 (Included)' : `+LKR ${incident.costDeltaLKR.toLocaleString()}`}
                      </span>
                      <span style={{ color: 'var(--text-secondary)' }}>
                        Timing Delta: <strong>+{incident.timingDeltaMinutes}m</strong>
                      </span>
                      <span className="badge badge-emerald" style={{ fontSize: '0.72rem' }}>
                        TripGraph: {incident.tripGraphFeasibility}
                      </span>
                    </div>
                  </div>

                  <p style={{ margin: 0, fontSize: '0.92rem', color: '#f8fafc', lineHeight: 1.5 }}>
                    {incident.proposedAction}
                  </p>

                  {incident.backupProvider && (
                    <div style={{ marginTop: '8px', fontSize: '0.82rem', color: 'var(--text-secondary)' }}>
                      Assigned Verified Standby: <strong style={{ color: 'var(--text-primary)' }}>{incident.backupProvider}</strong>
                    </div>
                  )}
                </div>

                {/* Action Controls */}
                <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px', alignItems: 'center', marginTop: '4px' }}>
                  {incident.status === 'PENDING_AUTHORIZATION' ? (
                    <>
                      <button
                        onClick={() => handleAutopilotDecision(incident.id, 'REJECTED')}
                        className="btn btn-secondary"
                        style={{ fontSize: '0.85rem', padding: '8px 18px', borderColor: 'var(--accent-ruby)', color: '#f87171' }}
                      >
                        Reject & Manual Concierge
                      </button>
                      <button
                        onClick={() => handleAutopilotDecision(incident.id, 'APPROVED')}
                        className="btn btn-primary"
                        style={{ fontSize: '0.85rem', padding: '8px 22px' }}
                      >
                        ✓ Authorize Dispatch & Notify Traveller
                      </button>
                    </>
                  ) : incident.status === 'DISPATCHED' ? (
                    <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                      <span className="badge badge-emerald">Dispatched to Fleet Hub & Traveller Notified</span>
                      <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>Audit Log Sealed</span>
                    </div>
                  ) : (
                    <span className="badge badge-ruby">Proposal Rejected (Manual Intervention Active)</span>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Tab: Atlas Moderation & Curation Desk */}
      {adminTab === 'atlas' && (
        <div className="glass-panel" style={{ padding: '32px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px', flexWrap: 'wrap', gap: '16px' }}>
            <div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <h2 style={{ fontSize: '1.4rem', margin: 0 }}>Island Atlas Moderation & Verification Desk</h2>
                <span className="badge badge-sapphire">25 Districts Active</span>
              </div>
              <p style={{ fontSize: '0.88rem', color: 'var(--text-secondary)', marginTop: '4px', marginBottom: 0 }}>
                Review, verify, and seal community corrections, seasonal access alerts, and newly submitted landmarks before public indexing.
              </p>
            </div>

            <div style={{ display: 'flex', gap: '12px' }}>
              <div style={{ background: 'rgba(255, 255, 255, 0.04)', padding: '8px 16px', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border-glass)', textAlign: 'center' }}>
                <div style={{ fontSize: '1.2rem', fontWeight: 700, color: 'var(--accent-teal)' }}>
                  {atlasContributions.filter((c) => c.status === 'PENDING').length}
                </div>
                <div style={{ fontSize: '0.72rem', color: 'var(--text-muted)', textTransform: 'uppercase' }}>Pending Review</div>
              </div>
              <div style={{ background: 'rgba(255, 255, 255, 0.04)', padding: '8px 16px', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border-glass)', textAlign: 'center' }}>
                <div style={{ fontSize: '1.2rem', fontWeight: 700, color: 'var(--accent-emerald)' }}>
                  {atlasContributions.filter((c) => c.status === 'APPROVED').length}
                </div>
                <div style={{ fontSize: '0.72rem', color: 'var(--text-muted)', textTransform: 'uppercase' }}>Approved & Live</div>
              </div>
              <Link href="/atlas" className="btn btn-secondary" style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                <span>Preview Atlas</span> ↗
              </Link>
            </div>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '18px' }}>
            {atlasContributions.map((contrib) => (
              <div
                key={contrib.id}
                style={{
                  background: 'rgba(16, 42, 67, 0.4)',
                  padding: '24px',
                  borderRadius: 'var(--radius-md)',
                  border:
                    contrib.status === 'PENDING'
                      ? '1px solid rgba(245, 158, 11, 0.4)'
                      : contrib.status === 'APPROVED'
                      ? '1px solid rgba(16, 185, 129, 0.3)'
                      : '1px solid var(--border-glass)',
                  display: 'flex',
                  flexDirection: 'column',
                  gap: '14px',
                }}
              >
                {/* Header Row */}
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: '12px' }}>
                  <div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '10px', flexWrap: 'wrap' }}>
                      <span
                        className={`badge ${
                          contrib.type === 'ROAD_ACCESS_ALERT'
                            ? 'badge-amber'
                            : contrib.type === 'NEW_DESTINATION'
                            ? 'badge-sapphire'
                            : 'badge-emerald'
                        }`}
                        style={{ fontSize: '0.75rem' }}
                      >
                        {contrib.type.replace(/_/g, ' ')}
                      </span>
                      <span style={{ fontFamily: 'monospace', fontSize: '0.85rem', color: 'var(--text-muted)' }}>
                        #{contrib.id}
                      </span>
                      <span style={{ fontSize: '0.85rem', color: 'var(--accent-teal)', fontWeight: 600 }}>
                        {contrib.district} District · {contrib.province}
                      </span>
                    </div>
                    <h3 style={{ fontSize: '1.15rem', margin: '8px 0 0 0', color: '#f8fafc' }}>
                      {contrib.destinationName}
                    </h3>
                  </div>

                  <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                    <span
                      className={`badge ${
                        contrib.status === 'APPROVED'
                          ? 'badge-emerald'
                          : contrib.status === 'REJECTED'
                          ? 'badge-ruby'
                          : contrib.status === 'NEEDS_EVIDENCE'
                          ? 'badge-amber'
                          : 'badge-sapphire'
                      }`}
                    >
                      {contrib.status.replace(/_/g, ' ')}
                    </span>
                    <span style={{ fontSize: '0.78rem', color: 'var(--text-muted)' }}>
                      Submitted {contrib.submittedAt}
                    </span>
                  </div>
                </div>

                {/* Submitter & Trust Score */}
                <div style={{ display: 'flex', alignItems: 'center', gap: '16px', fontSize: '0.84rem', color: 'var(--text-secondary)' }}>
                  <span>
                    Contributor: <strong style={{ color: 'var(--text-primary)' }}>{contrib.contributor}</strong>
                  </span>
                  <span>•</span>
                  <span>
                    Trust Score: <strong style={{ color: 'var(--accent-emerald)' }}>{contrib.contributorTrustScore}/100</strong>
                  </span>
                </div>

                {/* Proposed Detail */}
                <div style={{ background: 'rgba(0, 0, 0, 0.25)', padding: '14px 18px', borderRadius: 'var(--radius-sm)', border: '1px solid rgba(255, 255, 255, 0.05)' }}>
                  <div style={{ fontSize: '0.78rem', color: 'var(--text-muted)', marginBottom: '4px', textTransform: 'uppercase', letterSpacing: '0.04em' }}>
                    Proposed Contribution / Field Report
                  </div>
                  <div style={{ fontSize: '0.92rem', color: '#f1f5f9', lineHeight: 1.5 }}>
                    {contrib.details}
                  </div>
                </div>

                {/* Evidence & Provenance */}
                <div style={{ background: 'rgba(11, 110, 142, 0.1)', padding: '12px 16px', borderRadius: 'var(--radius-sm)', border: '1px solid rgba(27, 166, 166, 0.2)' }}>
                  <div style={{ fontSize: '0.78rem', color: 'var(--accent-teal)', textTransform: 'uppercase', letterSpacing: '0.04em', fontWeight: 600, marginBottom: '4px' }}>
                    🛡️ Verification Evidence Provided
                  </div>
                  <div style={{ fontSize: '0.85rem', color: '#e2e8f0' }}>
                    {contrib.evidence}
                  </div>
                </div>

                {/* Actions */}
                <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px', alignItems: 'center', marginTop: '6px' }}>
                  {contrib.status === 'PENDING' ? (
                    <>
                      <button
                        onClick={() => handleAtlasDecision(contrib.id, 'REJECTED')}
                        className="btn btn-secondary"
                        style={{ fontSize: '0.82rem', padding: '7px 16px', color: '#f87171', borderColor: 'rgba(239, 68, 68, 0.4)' }}
                      >
                        Reject
                      </button>
                      <button
                        onClick={() => handleAtlasDecision(contrib.id, 'NEEDS_EVIDENCE')}
                        className="btn btn-secondary"
                        style={{ fontSize: '0.82rem', padding: '7px 16px', color: '#fbbf24', borderColor: 'rgba(245, 158, 11, 0.4)' }}
                      >
                        Request More Evidence
                      </button>
                      <button
                        onClick={() => handleAtlasDecision(contrib.id, 'APPROVED')}
                        className="btn btn-primary"
                        style={{ fontSize: '0.82rem', padding: '7px 20px' }}
                      >
                        ✓ Verify & Publish to Atlas
                      </button>
                    </>
                  ) : contrib.status === 'APPROVED' ? (
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                      <span className="badge badge-emerald">Published to Atlas 25 Districts</span>
                      <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>Indexed in Multi-Lingual Search</span>
                    </div>
                  ) : contrib.status === 'NEEDS_EVIDENCE' ? (
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                      <span className="badge badge-amber">Awaiting Contributor Field Photos</span>
                      <button
                        onClick={() => handleAtlasDecision(contrib.id, 'APPROVED')}
                        className="btn btn-primary"
                        style={{ fontSize: '0.78rem', padding: '5px 14px' }}
                      >
                        Force Verify
                      </button>
                    </div>
                  ) : (
                    <span className="badge badge-ruby">Rejected & Archived</span>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Tab: Community Moderation Desk */}
      {adminTab === 'community' && (
        <div className="glass-panel" style={{ padding: '32px' }}>
          <div
            style={{
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center',
              marginBottom: '24px',
              flexWrap: 'wrap',
              gap: '16px',
            }}
          >
            <div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <h2 style={{ fontSize: '1.4rem', margin: 0 }}>Community Moderation & Safety Desk</h2>
                <span className="badge badge-ruby">
                  {communityReports.filter((r) => r.status === 'PENDING').length} Pending Review
                </span>
              </div>
              <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginTop: '6px', marginBottom: 0 }}>
                Apple UGC & SL-DPA Compliance · Audit-logged content removal, user warning, and safety flag actions.
              </p>
            </div>

            <div style={{ display: 'flex', gap: '8px' }}>
              <span className="badge badge-emerald">Audit Trail Linked</span>
              <span className="badge badge-sapphire">EXIF Stripping Enforced</span>
            </div>
          </div>

          {/* Reports List */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            {communityReports.map((report) => (
              <div
                key={report.id}
                style={{
                  background: 'rgba(255, 255, 255, 0.02)',
                  border: '1px solid var(--border-glass)',
                  borderRadius: 'var(--radius-sm)',
                  padding: '24px',
                  display: 'flex',
                  flexDirection: 'column',
                  gap: '14px',
                }}
              >
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: '12px' }}>
                  <div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                      <strong style={{ fontSize: '1.05rem', color: 'var(--color-primary)' }}>
                        Case {report.id} · {report.targetType} Report
                      </strong>
                      <span
                        className={`badge ${
                          report.reason === 'SAFETY_CONCERN'
                            ? 'badge-ruby'
                            : report.reason === 'MISLEADING_ADVICE'
                            ? 'badge-amber'
                            : 'badge-sapphire'
                        }`}
                      >
                        {report.reason.replace('_', ' ')}
                      </span>
                      <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>
                        Reported {report.reportedAt}
                      </span>
                    </div>
                    <div style={{ fontSize: '0.82rem', color: 'var(--text-secondary)', marginTop: '4px' }}>
                      Author: <strong>{report.reportedItemAuthor}</strong> • Reported by: <strong>{report.reporterName}</strong>
                    </div>
                  </div>

                  <div style={{ fontSize: '0.82rem', color: 'var(--color-secondary)', fontWeight: 600 }}>
                    📍 {report.destination || report.district} ({report.district} District)
                  </div>
                </div>

                <div
                  style={{
                    background: 'rgba(0, 0, 0, 0.03)',
                    padding: '14px',
                    borderRadius: 'var(--radius-sm)',
                    borderLeft: '4px solid var(--accent-ruby)',
                  }}
                >
                  <div style={{ fontSize: '0.78rem', fontWeight: 800, color: 'var(--text-muted)', marginBottom: '4px' }}>
                    REPORTED CONTENT EXCERPT / VIOLATION SUMMARY:
                  </div>
                  <p style={{ fontSize: '0.88rem', margin: 0, color: 'var(--text-primary)', lineHeight: 1.5 }}>
                    &ldquo;{report.excerpt}&rdquo;
                  </p>
                </div>

                {report.moderatorNotes && (
                  <div style={{ fontSize: '0.82rem', color: 'var(--accent-emerald)', fontWeight: 600 }}>
                    Moderator Note: {report.moderatorNotes}
                  </div>
                )}

                {/* Moderation Actions */}
                <div
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    borderTop: '1px solid rgba(0, 0, 0, 0.05)',
                    paddingTop: '14px',
                    flexWrap: 'wrap',
                    gap: '12px',
                  }}
                >
                  {report.status === 'PENDING' ? (
                    <>
                      <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap' }}>
                        <button
                          onClick={() => handleCommunityDecision(report.id, 'APPROVED_SAFE', 'Report reviewed; content complies with community guidelines.')}
                          className="btn btn-secondary"
                          style={{ fontSize: '0.82rem', padding: '6px 14px' }}
                        >
                          ✓ Dismiss Report & Keep
                        </button>
                        <button
                          onClick={() => handleCommunityDecision(report.id, 'FLAGGED', 'Marked as safety warning pending local ranger verification.')}
                          className="btn btn-secondary"
                          style={{ fontSize: '0.82rem', padding: '6px 14px', color: '#D97706', borderColor: '#D97706' }}
                        >
                          ⚠️ Flag for Safety Review
                        </button>
                        <button
                          onClick={() => handleCommunityDecision(report.id, 'REMOVED', 'Removed for violating safety guidelines and misleading advice.')}
                          className="btn btn-primary"
                          style={{ fontSize: '0.82rem', padding: '6px 14px', background: 'var(--accent-ruby)' }}
                        >
                          🗑️ Remove Content
                        </button>
                      </div>
                      <span style={{ fontSize: '0.78rem', color: 'var(--text-muted)' }}>
                        Action logs to append-only audit trail
                      </span>
                    </>
                  ) : report.status === 'APPROVED_SAFE' ? (
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                      <span className="badge badge-emerald">✓ Approved & Retained</span>
                      <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>Visible in Community Pulse feed</span>
                    </div>
                  ) : report.status === 'FLAGGED' ? (
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                      <span className="badge badge-amber">⚠️ Under Active Safety Review</span>
                      <button
                        onClick={() => handleCommunityDecision(report.id, 'REMOVED', 'Safety review concluded: removed permanently.')}
                        className="btn btn-primary"
                        style={{ fontSize: '0.78rem', padding: '4px 12px', background: 'var(--accent-ruby)' }}
                      >
                        Force Remove
                      </button>
                    </div>
                  ) : (
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                      <span className="badge badge-ruby">🗑️ Content Removed</span>
                      <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>Purged from CDN and hidden from search</span>
                    </div>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Tab 3: Immutable Audit Log Stream */}
      {adminTab === 'audit' && (
        <div className="glass-panel" style={{ padding: '32px' }}>
          <h2 style={{ fontSize: '1.3rem', marginBottom: '8px' }}>Immutable Regulatory Audit Trail</h2>
          <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginBottom: '24px' }}>
            Section 15: Read-only, append-only logs for all operational state changes and financial movements.
          </p>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
            {[
              {
                time: '2026-10-20 03:22 UTC',
                actor: 'nirosha@traverza.lk (SUPER_ADMIN)',
                action: 'ORGANIZATION_VERIFY',
                target: 'Ceylon Chauffeurs Guild (Pvt) Ltd',
                reason: 'SLTDA registry match confirmed for SLTDA/CG/2026/102',
              },
              {
                time: '2026-10-20 03:10 UTC',
                actor: 'webhook-worker (PAYMENTS_GATEWAY)',
                action: 'WEBHOOK_PAYMENT_CAPTURED',
                target: 'Trip #TRIP-LK-2026-9041',
                reason: 'Verified PayHere signature for LKR 18,500. Escrow credited.',
              },
              {
                time: '2026-10-20 02:45 UTC',
                actor: 'nimali@traverza.lk (TRIP_OPS)',
                action: 'SUPPORT_CASE_RESOLVED',
                target: 'CASE-401 (Driver Breakdown Rescue)',
                reason: 'Backup Prado dispatched from Negombo fleet hub.',
              },
            ].map((log, i) => (
              <div
                key={i}
                style={{
                  padding: '16px',
                  background: 'rgba(255, 255, 255, 0.02)',
                  borderRadius: 'var(--radius-sm)',
                  border: '1px solid var(--border-glass)',
                  fontSize: '0.85rem',
                }}
              >
                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '4px' }}>
                  <strong style={{ color: 'var(--accent-emerald)' }}>{log.action}</strong>
                  <span style={{ color: 'var(--text-muted)', fontSize: '0.78rem' }}>{log.time}</span>
                </div>
                <div style={{ color: 'var(--text-secondary)' }}>
                  Actor: <strong>{log.actor}</strong> • Target: <strong>{log.target}</strong>
                </div>
                <div style={{ color: '#f8fafc', marginTop: '4px', fontSize: '0.82rem' }}>
                  Reason: {log.reason}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
