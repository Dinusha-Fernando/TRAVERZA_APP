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

export default function AdminOpsPage() {
  const [exceptions, setExceptions] = useState<ExceptionItem[]>(INITIAL_EXCEPTIONS);
  const [verifications, setVerifications] = useState<ProviderVerificationItem[]>(INITIAL_VERIFICATIONS);
  const [packageReviews, setPackageReviews] = useState<PackageReviewItem[]>(INITIAL_PACKAGE_REVIEWS);
  const [activeCaseId, setActiveCaseId] = useState<string>('CASE-401');
  const [adminTab, setAdminTab] = useState<'exceptions' | 'verification' | 'packages' | 'audit'>('exceptions');
  const [resolutionInput, setResolutionInput] = useState('');
  const [notification, setNotification] = useState<string | null>(null);

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
