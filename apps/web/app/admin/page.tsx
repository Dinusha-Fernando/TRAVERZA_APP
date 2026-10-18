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
}

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

export default function AdminOpsPage() {
  const [exceptions, setExceptions] = useState<ExceptionItem[]>(INITIAL_EXCEPTIONS);
  const [activeCaseId, setActiveCaseId] = useState<string>('CASE-401');

  const activeCase = exceptions.find((c) => c.id === activeCaseId) || exceptions[0];

  const handleResolve = (caseId: string) => {
    setExceptions((prev) =>
      prev.map((c) => (c.id === caseId ? { ...c, status: 'RESOLVED' } : c))
    );
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
          gap: '16px',
        }}
      >
        <div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <h1 style={{ fontSize: '2.2rem' }}>Trip Operations & Exception Desk</h1>
            <span className="badge badge-ruby">MFA Authenticated</span>
          </div>
          <p style={{ color: 'var(--text-secondary)', marginTop: '4px' }}>
            Priority Incident Resolution • Tenant Audited • SLTDA Grievance Compliance
          </p>
        </div>

        <div style={{ display: 'flex', gap: '12px' }}>
          <Link href="/" className="btn btn-secondary">
            Live Explorer
          </Link>
          <button className="btn btn-primary">Export Regulatory Incident Log</button>
        </div>
      </div>

      {/* Exception-first 2-column layout */}
      <div style={{ display: 'grid', gridTemplateColumns: 'minmax(0, 1fr) 420px', gap: '32px' }}>
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
                    >
                      {exc.severity}
                    </span>
                    <span style={{ fontSize: '0.85rem', fontWeight: 600 }}>{exc.id}</span>
                    <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>
                      • {exc.tripId}
                    </span>
                  </div>

                  <span
                    style={{
                      fontSize: '0.8rem',
                      color: exc.deadlineMinutes < 60 ? 'var(--accent-ruby)' : 'var(--accent-amber)',
                      fontWeight: 600,
                    }}
                  >
                    ⏳ {exc.deadlineMinutes}m target
                  </span>
                </div>

                <div style={{ fontSize: '0.95rem', fontWeight: 600, marginTop: '6px' }}>
                  {exc.category}
                </div>
                <div style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginTop: '4px' }}>
                  {exc.impact}
                </div>

                <div
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    marginTop: '12px',
                    paddingTop: '10px',
                    borderTop: '1px solid var(--border-glass)',
                    fontSize: '0.8rem',
                    color: 'var(--text-muted)',
                  }}
                >
                  <span>
                    Owner: <strong style={{ color: 'var(--text-primary)' }}>{exc.owner}</strong>
                  </span>
                  <span
                    className={`badge ${
                      exc.status === 'RESOLVED' ? 'badge-emerald' : 'badge-amber'
                    }`}
                  >
                    {exc.status}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Right Column: Case Action & Resolution Workspace */}
        <div>
          <div className="glass-panel" style={{ padding: '28px', position: 'sticky', top: '100px' }}>
            <h3 style={{ fontSize: '1.2rem', marginBottom: '4px' }}>
              Incident Resolution: {activeCase.id}
            </h3>
            <p style={{ fontSize: '0.85rem', color: 'var(--text-muted)', marginBottom: '20px' }}>
              Severity: <strong>{activeCase.severity}</strong> • Trip: <strong>{activeCase.tripId}</strong>
            </p>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '14px', fontSize: '0.88rem' }}>
              <div>
                <span style={{ color: 'var(--text-secondary)' }}>Affected Parties:</span>
                <div style={{ fontWeight: 600, marginTop: '2px' }}>{activeCase.affectedParties}</div>
              </div>

              <div>
                <span style={{ color: 'var(--text-secondary)' }}>TripGraph Dependency Cascade:</span>
                <div
                  style={{
                    background: 'rgba(244, 63, 94, 0.08)',
                    border: '1px solid rgba(244, 63, 94, 0.25)',
                    padding: '10px',
                    borderRadius: 'var(--radius-sm)',
                    fontSize: '0.82rem',
                    color: '#fb7185',
                    marginTop: '6px',
                  }}
                >
                  ⚡ Item #2 (Airport Transfer) marked as INVALID. Item #3 (Sigiriya Check-in) flagged as AT_RISK.
                </div>
              </div>

              <div>
                <label style={{ display: 'block', color: 'var(--text-secondary)', marginBottom: '6px' }}>
                  Action / Resolution Plan:
                </label>
                <textarea
                  rows={4}
                  defaultValue="Dispatched replacement backup driver (Fleet #LK-409, SLTDA Licensed). Traveller notified in mobile app with revised pickup PIN. ETA difference: +15 mins (within transit buffer)."
                  style={{
                    width: '100%',
                    background: 'rgba(255, 255, 255, 0.04)',
                    border: '1px solid var(--border-glass)',
                    borderRadius: 'var(--radius-sm)',
                    color: '#fff',
                    padding: '10px',
                    fontFamily: 'inherit',
                    fontSize: '0.85rem',
                  }}
                />
              </div>

              <div style={{ display: 'flex', flexDirection: 'column', gap: '10px', marginTop: '10px' }}>
                <button
                  onClick={() => handleResolve(activeCase.id)}
                  disabled={activeCase.status === 'RESOLVED'}
                  className="btn btn-primary"
                  style={{ width: '100%' }}
                >
                  {activeCase.status === 'RESOLVED' ? '✓ Case Resolved & Audited' : 'Execute Replacement & Resolve Case'}
                </button>
                <button className="btn btn-secondary" style={{ width: '100%' }}>
                  Issue Authorised Traveler Credit Note
                </button>
              </div>

              <div
                style={{
                  marginTop: '16px',
                  padding: '12px',
                  borderRadius: 'var(--radius-sm)',
                  background: 'rgba(255, 255, 255, 0.02)',
                  fontSize: '0.78rem',
                  color: 'var(--text-muted)',
                  border: '1px solid var(--border-glass)',
                }}
              >
                📝 Resolution commits an append-only event to <code>audit_events</code> with actor identity, timestamp, and justification.
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
