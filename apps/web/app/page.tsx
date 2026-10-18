'use client';

import { useState } from 'react';
import Link from 'next/link';

interface ItineraryStop {
  id: string;
  day: number;
  time: string;
  title: string;
  category: 'TRANSFER' | 'STAY' | 'ACTIVITY';
  location: string;
  provider: string;
  status: 'CONFIRMED' | 'REQUEST_SUBMITTED' | 'UNCONFIRMED';
  priceLKR: number;
}

const INITIAL_STOPS: ItineraryStop[] = [
  {
    id: 'stop-1',
    day: 1,
    time: '09:00 - 10:00',
    title: 'Bandaranaike Intl Airport (CMB) Arrival',
    category: 'TRANSFER',
    location: 'Katunayake',
    provider: 'SLTDA Chauffeur Guide (Fleet #LK-402)',
    status: 'CONFIRMED',
    priceLKR: 18500,
  },
  {
    id: 'stop-2',
    day: 1,
    time: '14:30 - 17:30',
    title: 'Sigiriya Rock Fortress Guided Ascent',
    category: 'ACTIVITY',
    location: 'Sigiriya',
    provider: 'Cultural Heritage Guide Guild',
    status: 'CONFIRMED',
    priceLKR: 12000,
  },
  {
    id: 'stop-3',
    day: 1,
    time: '18:30 Check-in',
    title: 'Sigiriya Water Garden Eco Villa',
    category: 'STAY',
    location: 'Dambulla / Sigiriya',
    provider: 'Boutique Heritage Stays Ltd',
    status: 'REQUEST_SUBMITTED',
    priceLKR: 38000,
  },
  {
    id: 'stop-4',
    day: 2,
    time: '09:00 - 11:30',
    title: 'Temple of the Sacred Tooth Relic',
    category: 'ACTIVITY',
    location: 'Kandy',
    provider: 'Certified Central Guide Guild',
    status: 'UNCONFIRMED',
    priceLKR: 9500,
  },
];

export default function HomePage() {
  const [stops, setStops] = useState<ItineraryStop[]>(INITIAL_STOPS);
  const [activeTab, setActiveTab] = useState<'timeline' | 'corridor' | 'validation'>('timeline');

  // Compute truthful trip status (Gate 6)
  const confirmedCount = stops.filter((s) => s.status === 'CONFIRMED').length;
  const totalCount = stops.length;
  const overallTripStatus =
    confirmedCount === totalCount
      ? 'FULLY_CONFIRMED'
      : confirmedCount > 0
      ? 'PARTIALLY_CONFIRMED'
      : 'DRAFT';

  const totalPriceLKR = stops.reduce((acc, s) => acc + s.priceLKR, 0);

  return (
    <div style={{ maxWidth: '1280px', margin: '0 auto', padding: '40px 24px' }}>
      {/* Hero Section */}
      <section
        style={{
          textAlign: 'center',
          padding: '60px 0 40px',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
        }}
      >
        <div style={{ marginBottom: '16px' }}>
          <span className="badge badge-emerald">
            Sri Lanka Pilot Corridor • Verified Operating Platform
          </span>
        </div>
        <h1
          style={{
            fontSize: '3.2rem',
            lineHeight: 1.15,
            marginBottom: '20px',
            maxWidth: '900px',
            background: 'linear-gradient(180deg, #FFFFFF 0%, #94A3B8 100%)',
            WebkitBackgroundClip: 'text',
            WebkitTextFillColor: 'transparent',
          }}
        >
          One trip. Connected services. A journey that adapts.
        </h1>
        <p
          style={{
            fontSize: '1.2rem',
            color: 'var(--text-secondary)',
            maxWidth: '680px',
            marginBottom: '36px',
          }}
        >
          Coordinate multi-stop travel across Sri Lanka with real-time dependency validation, verified local providers, and an authoritative Trip ID.
        </p>

        <div style={{ display: 'flex', gap: '16px', flexWrap: 'wrap', justifyContent: 'center' }}>
          <button
            onClick={() => setActiveTab('timeline')}
            className={`btn ${activeTab === 'timeline' ? 'btn-primary' : 'btn-secondary'}`}
          >
            Live Itinerary Timeline
          </button>
          <button
            onClick={() => setActiveTab('corridor')}
            className={`btn ${activeTab === 'corridor' ? 'btn-primary' : 'btn-secondary'}`}
          >
            Pilot Corridor Map
          </button>
          <button
            onClick={() => setActiveTab('validation')}
            className={`btn ${activeTab === 'validation' ? 'btn-primary' : 'btn-secondary'}`}
          >
            TripGraph Validator
          </button>
        </div>
      </section>

      {/* Main Interactive Workspace */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'minmax(0, 1fr) 380px',
          gap: '32px',
          marginTop: '20px',
        }}
      >
        {/* Left Column: Itinerary & Graph details */}
        <div>
          {activeTab === 'timeline' && (
            <div className="glass-panel" style={{ padding: '32px' }}>
              <div
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  marginBottom: '24px',
                  paddingBottom: '16px',
                  borderBottom: '1px solid var(--border-glass)',
                }}
              >
                <div>
                  <h2 style={{ fontSize: '1.4rem' }}>Colombo to Cultural Highlands (3-Day Journey)</h2>
                  <p style={{ color: 'var(--text-secondary)', fontSize: '0.88rem' }}>
                    Trip ID: <span style={{ fontFamily: 'monospace', color: 'var(--accent-emerald)' }}>TRIP-LK-2026-9041</span>
                  </p>
                </div>
                <div style={{ textAlign: 'right' }}>
                  <span
                    className={`badge ${
                      overallTripStatus === 'FULLY_CONFIRMED' ? 'badge-emerald' : 'badge-amber'
                    }`}
                  >
                    {overallTripStatus === 'FULLY_CONFIRMED'
                      ? 'Fully Confirmed'
                      : `Partially Confirmed (${confirmedCount}/${totalCount})`}
                  </span>
                </div>
              </div>

              {/* Stop Cards */}
              <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                {stops.map((stop, idx) => (
                  <div
                    key={stop.id}
                    style={{
                      background: 'rgba(255, 255, 255, 0.03)',
                      border: '1px solid var(--border-glass)',
                      borderRadius: 'var(--radius-sm)',
                      padding: '20px',
                      display: 'flex',
                      justifyContent: 'space-between',
                      alignItems: 'center',
                      transition: 'border-color var(--transition-fast)',
                    }}
                  >
                    <div style={{ display: 'flex', gap: '20px', alignItems: 'center' }}>
                      <div
                        style={{
                          width: '44px',
                          height: '44px',
                          borderRadius: '12px',
                          background:
                            stop.category === 'TRANSFER'
                              ? 'rgba(59, 130, 246, 0.2)'
                              : stop.category === 'STAY'
                              ? 'rgba(16, 185, 129, 0.2)'
                              : 'rgba(245, 158, 11, 0.2)',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                          fontWeight: 700,
                          fontSize: '0.9rem',
                          color:
                            stop.category === 'TRANSFER'
                              ? '#60a5fa'
                              : stop.category === 'STAY'
                              ? '#34d399'
                              : '#fbbf24',
                        }}
                      >
                        D{stop.day}
                      </div>
                      <div>
                        <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>
                          {stop.time} • {stop.location}
                        </div>
                        <h3 style={{ fontSize: '1.05rem', marginTop: '2px' }}>{stop.title}</h3>
                        <div style={{ fontSize: '0.82rem', color: 'var(--text-secondary)' }}>
                          {stop.provider}
                        </div>
                      </div>
                    </div>

                    <div style={{ textAlign: 'right' }}>
                      <div
                        style={{
                          fontFamily: 'var(--font-heading)',
                          fontWeight: 700,
                          fontSize: '1rem',
                        }}
                      >
                        LKR {stop.priceLKR.toLocaleString()}
                      </div>
                      <div style={{ marginTop: '6px' }}>
                        {stop.status === 'CONFIRMED' && (
                          <span className="badge badge-emerald" style={{ fontSize: '0.72rem' }}>
                            Confirmed
                          </span>
                        )}
                        {stop.status === 'REQUEST_SUBMITTED' && (
                          <span className="badge badge-amber" style={{ fontSize: '0.72rem' }}>
                            Request Pending (12h Expiry)
                          </span>
                        )}
                        {stop.status === 'UNCONFIRMED' && (
                          <span className="badge badge-sapphire" style={{ fontSize: '0.72rem' }}>
                            Draft Selection
                          </span>
                        )}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {activeTab === 'corridor' && (
            <div className="glass-panel" style={{ padding: '32px' }}>
              <h2 style={{ fontSize: '1.4rem', marginBottom: '8px' }}>
                Primary Corridor: Colombo $\rightarrow$ Sigiriya $\rightarrow$ Kandy $\rightarrow$ Nuwara Eliya
              </h2>
              <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', marginBottom: '24px' }}>
                Curated route cluster with verified highway transit buffers, mountain speed models, and certified local provider guilds.
              </p>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '20px' }}>
                <div
                  style={{
                    padding: '20px',
                    background: 'rgba(255, 255, 255, 0.03)',
                    borderRadius: 'var(--radius-sm)',
                    border: '1px solid var(--border-glass)',
                  }}
                >
                  <span className="badge badge-sapphire" style={{ marginBottom: '10px' }}>Leg 1: Airport to Cultural Triangle</span>
                  <h4 style={{ fontSize: '1.1rem', marginTop: '6px' }}>CMB $\rightarrow$ Dambulla / Sigiriya</h4>
                  <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginTop: '6px' }}>
                    Distance: 148 km • Modelled Drive: 3h 15m (A1/A6 Highway + Buffer).
                  </p>
                  <p style={{ fontSize: '0.8rem', color: 'var(--accent-emerald)', marginTop: '8px' }}>
                    ✓ Monitored Chauffeur Fleet Available
                  </p>
                </div>

                <div
                  style={{
                    padding: '20px',
                    background: 'rgba(255, 255, 255, 0.03)',
                    borderRadius: 'var(--radius-sm)',
                    border: '1px solid var(--border-glass)',
                  }}
                >
                  <span className="badge badge-amber" style={{ marginBottom: '10px' }}>Leg 2: Highland Mountain Climb</span>
                  <h4 style={{ fontSize: '1.1rem', marginTop: '6px' }}>Kandy $\rightarrow$ Nuwara Eliya</h4>
                  <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginTop: '6px' }}>
                    Distance: 76 km • Modelled Drive: 2h 45m (Highland winding terrain 32 km/h).
                  </p>
                  <p style={{ fontSize: '0.8rem', color: 'var(--accent-amber)', marginTop: '8px' }}>
                    ⚠ Enforces 45-min mountain buffer
                  </p>
                </div>
              </div>
            </div>
          )}

          {activeTab === 'validation' && (
            <div className="glass-panel" style={{ padding: '32px' }}>
              <h2 style={{ fontSize: '1.4rem', marginBottom: '8px' }}>TripGraph Engine Rule Check</h2>
              <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', marginBottom: '24px' }}>
                Deterministic verification ensures physical feasibility before quotes are snapshot.
              </p>

              <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
                <div
                  style={{
                    padding: '16px',
                    borderRadius: 'var(--radius-sm)',
                    background: 'rgba(16, 185, 129, 0.08)',
                    border: '1px solid rgba(16, 185, 129, 0.3)',
                  }}
                >
                  <div style={{ fontWeight: 600, color: '#34d399' }}>✓ Temporal Non-Overlap Check</div>
                  <div style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginTop: '4px' }}>
                    Zero clashing fixed-time reservations detected across Days 1–3.
                  </div>
                </div>

                <div
                  style={{
                    padding: '16px',
                    borderRadius: 'var(--radius-sm)',
                    background: 'rgba(16, 185, 129, 0.08)',
                    border: '1px solid rgba(16, 185, 129, 0.3)',
                  }}
                >
                  <div style={{ fontWeight: 600, color: '#34d399' }}>✓ Sri Lanka Terrain Transit Buffer Check</div>
                  <div style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginTop: '4px' }}>
                    All intercity legs satisfy realistic mountain and highway speed models.
                  </div>
                </div>

                <div
                  style={{
                    padding: '16px',
                    borderRadius: 'var(--radius-sm)',
                    background: 'rgba(245, 158, 11, 0.08)',
                    border: '1px solid rgba(245, 158, 11, 0.3)',
                  }}
                >
                  <div style={{ fontWeight: 600, color: '#fbbf24' }}>⚠ Advisory Notice: Sigiriya Eco Villa</div>
                  <div style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginTop: '4px' }}>
                    Request-to-confirm offer pending. Quote expires in 11 hours 42 minutes.
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Right Column: Trip Cost & Status Summary */}
        <div>
          <div className="glass-panel" style={{ padding: '28px', position: 'sticky', top: '100px' }}>
            <h3 style={{ fontSize: '1.2rem', marginBottom: '16px' }}>Trip Readiness</h3>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px', marginBottom: '24px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.9rem' }}>
                <span style={{ color: 'var(--text-secondary)' }}>Status:</span>
                <span style={{ fontWeight: 600, color: '#fbbf24' }}>Partially Confirmed</span>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.9rem' }}>
                <span style={{ color: 'var(--text-secondary)' }}>Confirmed Items:</span>
                <span>{confirmedCount} of {totalCount}</span>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.9rem' }}>
                <span style={{ color: 'var(--text-secondary)' }}>Currency:</span>
                <span>LKR (Sri Lankan Rupee)</span>
              </div>
              <div
                style={{
                  height: '1px',
                  background: 'var(--border-glass)',
                  margin: '8px 0',
                }}
              />
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <span style={{ fontSize: '1rem', fontWeight: 600 }}>Estimated Total:</span>
                <span
                  style={{
                    fontFamily: 'var(--font-heading)',
                    fontSize: '1.4rem',
                    fontWeight: 800,
                    color: 'var(--accent-emerald)',
                  }}
                >
                  LKR {totalPriceLKR.toLocaleString()}
                </span>
              </div>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              <Link
                href="/provider"
                className="btn btn-primary"
                style={{ width: '100%', textAlign: 'center' }}
              >
                Simulate Provider Acceptance
              </Link>
              <Link
                href="/admin"
                className="btn btn-secondary"
                style={{ width: '100%', textAlign: 'center' }}
              >
                Inspect Central Exception Queue
              </Link>
            </div>

            <div
              style={{
                marginTop: '24px',
                padding: '16px',
                background: 'rgba(255, 255, 255, 0.02)',
                borderRadius: 'var(--radius-sm)',
                border: '1px solid var(--border-glass)',
                fontSize: '0.78rem',
                color: 'var(--text-muted)',
                lineHeight: 1.5,
              }}
            >
              🔒 <strong>Truth Before Convenience:</strong> TRAVERZA never claims an itinerary is confirmed while components await provider review.
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
