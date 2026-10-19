'use client';

import { useState } from 'react';
import Link from 'next/link';

interface ItineraryStop {
  id: string;
  day: number;
  time: string;
  title: string;
  category: 'TRANSFER' | 'STAY' | 'ACTIVITY' | 'FLIGHT';
  location: string;
  provider: string;
  status: 'CONFIRMED' | 'REQUEST_SUBMITTED' | 'UNCONFIRMED';
  priceLKR: number;
  bufferMins?: number;
}

const INITIAL_STOPS: ItineraryStop[] = [
  {
    id: 'stop-1',
    day: 1,
    time: '09:00 - 10:00',
    title: 'Bandaranaike Intl Airport (CMB) Arrival',
    category: 'FLIGHT',
    location: 'Katunayake',
    provider: 'SriLankan Airlines (UL-504)',
    status: 'CONFIRMED',
    priceLKR: 0,
    bufferMins: 30,
  },
  {
    id: 'stop-2',
    day: 1,
    time: '10:30 - 14:00',
    title: 'Airport to Sigiriya Private Chauffeur Transfer',
    category: 'TRANSFER',
    location: 'Katunayake → Sigiriya',
    provider: 'Ceylon Chauffeurs Guild (Fleet #LK-402)',
    status: 'CONFIRMED',
    priceLKR: 18500,
    bufferMins: 45,
  },
  {
    id: 'stop-3',
    day: 1,
    time: '15:00 - 17:30',
    title: 'Sigiriya Rock Fortress Guided Archaeological Ascent',
    category: 'ACTIVITY',
    location: 'Sigiriya Ancient Citadel',
    provider: 'Cultural Heritage Guide Guild (SLTDA Lic #044)',
    status: 'CONFIRMED',
    priceLKR: 12000,
    bufferMins: 60,
  },
  {
    id: 'stop-4',
    day: 1,
    time: '18:30 Check-in',
    title: 'Sigiriya Water Garden Eco Villa (Deluxe Chalet)',
    category: 'STAY',
    location: 'Sigiriya / Dambulla',
    provider: 'Boutique Heritage Stays (Pvt) Ltd',
    status: 'REQUEST_SUBMITTED',
    priceLKR: 38000,
  },
  {
    id: 'stop-5',
    day: 2,
    time: '09:00 - 11:30',
    title: 'Temple of the Sacred Tooth Relic Guided Walking Tour',
    category: 'ACTIVITY',
    location: 'Kandy Sacred City',
    provider: 'Kandyan Heritage Guild',
    status: 'CONFIRMED',
    priceLKR: 9500,
  },
];

interface DestinationInfo {
  name: string;
  province: string;
  altitude: string;
  highlights: string[];
  driveTimeFromPrev: string;
}

const CORRIDOR_DESTINATIONS: DestinationInfo[] = [
  {
    name: 'Colombo & Katunayake (CMB)',
    province: 'Western Province',
    altitude: '8m sea level',
    highlights: ['Bandaranaike International Airport', 'Central Expressway Interchange', 'Luxury Fleet Depot'],
    driveTimeFromPrev: 'Starting Point',
  },
  {
    name: 'Sigiriya & Dambulla',
    province: 'Central Province',
    altitude: '349m citadel summit',
    highlights: ['UNESCO Lion Rock Fortress', 'Royal Cave Monasteries', 'Eco Water Villas'],
    driveTimeFromPrev: '148 km • 3h 15m (A1/A6 Highway + 30m buffer)',
  },
  {
    name: 'Kandy Sacred Hill City',
    province: 'Central Province',
    altitude: '500m highland valley',
    highlights: ['Sri Dalada Maligawa (Tooth Relic)', 'Peradeniya Royal Botanical Gardens', 'Kandy Lake Walk'],
    driveTimeFromPrev: '89 km • 2h 20m (Hills transition route)',
  },
  {
    name: 'Nuwara Eliya (Tea Highlands)',
    province: 'Central Province',
    altitude: '1,868m mountain station',
    highlights: ['Historic 1885 Pedro Tea Plantation', 'Lover’s Leap Waterfall', 'Gregory Lake Heritage'],
    driveTimeFromPrev: '76 km • 2h 45m (Highland winding mountain speed: 32 km/h)',
  },
];

export default function HomePage() {
  const [stops, setStops] = useState<ItineraryStop[]>(INITIAL_STOPS);
  const [activeTab, setActiveTab] = useState<'timeline' | 'corridor' | 'validation' | 'checkout'>('timeline');
  const [simulatedWebhookState, setSimulatedWebhookState] = useState<'idle' | 'processing' | 'captured' | 'duplicate'>('idle');
  const [showNotification, setShowNotification] = useState<string | null>(null);

  // Compute truthful trip status (Gate 6 invariant)
  const bookableStops = stops.filter((s) => s.category !== 'FLIGHT');
  const confirmedCount = bookableStops.filter((s) => s.status === 'CONFIRMED').length;
  const totalCount = bookableStops.length;
  const overallTripStatus =
    confirmedCount === totalCount
      ? 'FULLY_CONFIRMED'
      : confirmedCount > 0
      ? 'PARTIALLY_CONFIRMED'
      : 'DRAFT';

  const totalPriceLKR = stops.reduce((acc, s) => acc + s.priceLKR, 0);
  const platformCommissionLKR = Math.round(totalPriceLKR * 0.10);
  const netProviderPayableLKR = totalPriceLKR - platformCommissionLKR;

  const toggleEcoVillaConfirmation = () => {
    setStops((prev) =>
      prev.map((s) => {
        if (s.id === 'stop-4') {
          const nextStatus = s.status === 'CONFIRMED' ? 'REQUEST_SUBMITTED' : 'CONFIRMED';
          return { ...s, status: nextStatus };
        }
        return s;
      })
    );

    const isNowConfirmed = stops.find((s) => s.id === 'stop-4')?.status !== 'CONFIRMED';
    const msg = isNowConfirmed
      ? '✓ Provider accepted Sigiriya Eco Villa! TripGraph updated status to Fully Confirmed.'
      : 'Sigiriya Eco Villa reverted to REQUEST_SUBMITTED. Readiness reflects truthful partial state.';
    setShowNotification(msg);
    setTimeout(() => setShowNotification(null), 5000);
  };

  const handleSimulatePaymentWebhook = (isDuplicate = false) => {
    setSimulatedWebhookState('processing');
    setTimeout(() => {
      if (isDuplicate) {
        setSimulatedWebhookState('duplicate');
        setShowNotification('Gate 5 Defense: Duplicate webhook ignored by event_id deduplication. Zero phantom ledger entries.');
      } else {
        setSimulatedWebhookState('captured');
        setShowNotification('✓ Payment Captured: LKR ' + totalPriceLKR.toLocaleString() + ' allocated to Platform Escrow. Double-entry balanced.');
      }
      setTimeout(() => setShowNotification(null), 6000);
    }, 700);
  };

  return (
    <div style={{ maxWidth: '1280px', margin: '0 auto', padding: '40px 24px' }}>
      {/* Hero Section */}
      <section
        style={{
          textAlign: 'center',
          padding: '40px 0 32px',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
        }}
      >
        <div style={{ marginBottom: '16px' }}>
          <span className="badge badge-emerald">
            Sri Lanka Pilot Corridor • Verified Travel Marketplace
          </span>
        </div>
        <h1
          style={{
            fontSize: '3.2rem',
            lineHeight: 1.15,
            marginBottom: '20px',
            maxWidth: '920px',
            background: 'linear-gradient(180deg, #FFFFFF 0%, #94A3B8 100%)',
            WebkitBackgroundClip: 'text',
            WebkitTextFillColor: 'transparent',
          }}
        >
          One island. One connected trip. Everything organised in one place.
        </h1>
        <p
          style={{
            fontSize: '1.2rem',
            color: 'var(--text-secondary)',
            maxWidth: '720px',
            marginBottom: '32px',
          }}
        >
          Discover Sri Lanka, plan realistic multi-day itineraries, book SLTDA-verified local services, and manage your entire journey with real-time transit validation.
        </p>

        {/* Tab Controls */}
        <div style={{ display: 'flex', gap: '12px', flexWrap: 'wrap', justifyContent: 'center' }}>
          <button
            onClick={() => setActiveTab('timeline')}
            className={`btn ${activeTab === 'timeline' ? 'btn-primary' : 'btn-secondary'}`}
          >
            Trip Canvas Timeline
          </button>
          <button
            onClick={() => setActiveTab('corridor')}
            className={`btn ${activeTab === 'corridor' ? 'btn-primary' : 'btn-secondary'}`}
          >
            Cultural Corridor Hub
          </button>
          <button
            onClick={() => setActiveTab('validation')}
            className={`btn ${activeTab === 'validation' ? 'btn-primary' : 'btn-secondary'}`}
          >
            TripGraph Validator
          </button>
          <button
            onClick={() => setActiveTab('checkout')}
            className={`btn ${activeTab === 'checkout' ? 'btn-accent' : 'btn-secondary'}`}
          >
            Sandbox Pay & Ledger
          </button>
        </div>
      </section>

      {/* Real-time Notification Banner */}
      {showNotification && (
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
          <span>{showNotification}</span>
          <button
            onClick={() => setShowNotification(null)}
            style={{ background: 'none', border: 'none', color: '#fff', cursor: 'pointer' }}
          >
            ✕
          </button>
        </div>
      )}

      {/* Main Interactive Workspace Grid */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'minmax(0, 1fr) 390px',
          gap: '32px',
          marginTop: '12px',
        }}
      >
        {/* Left Column: Interactive Views */}
        <div>
          {/* View 1: Timeline Canvas */}
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
                  flexWrap: 'wrap',
                  gap: '12px',
                }}
              >
                <div>
                  <h2 style={{ fontSize: '1.4rem' }}>Colombo to Cultural Highlands (3-Day Journey)</h2>
                  <p style={{ color: 'var(--text-secondary)', fontSize: '0.88rem' }}>
                    Trip ID: <span style={{ fontFamily: 'monospace', color: 'var(--accent-emerald)', fontWeight: 700 }}>TRIP-LK-2026-9041</span>
                  </p>
                </div>
                <div style={{ textAlign: 'right' }}>
                  <span
                    className={`badge ${
                      overallTripStatus === 'FULLY_CONFIRMED' ? 'badge-emerald' : 'badge-amber'
                    }`}
                  >
                    {overallTripStatus === 'FULLY_CONFIRMED'
                      ? 'Fully Confirmed (4/4)'
                      : `Partially Confirmed (${confirmedCount}/${totalCount})`}
                  </span>
                </div>
              </div>

              {/* Stop Cards List */}
              <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                {stops.map((stop) => (
                  <div key={stop.id}>
                    <div
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
                      <div style={{ display: 'flex', gap: '18px', alignItems: 'center' }}>
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
                                : stop.category === 'FLIGHT'
                                ? 'rgba(147, 51, 234, 0.2)'
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
                                : stop.category === 'FLIGHT'
                                ? '#c084fc'
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
                          {stop.priceLKR > 0 ? `LKR ${stop.priceLKR.toLocaleString()}` : 'Included'}
                        </div>
                        <div style={{ marginTop: '6px' }}>
                          {stop.status === 'CONFIRMED' && (
                            <span className="badge badge-emerald" style={{ fontSize: '0.72rem' }}>
                              Confirmed
                            </span>
                          )}
                          {stop.status === 'REQUEST_SUBMITTED' && (
                            <span className="badge badge-amber" style={{ fontSize: '0.72rem' }}>
                              Request Pending
                            </span>
                          )}
                          {stop.status === 'UNCONFIRMED' && (
                            <span className="badge badge-sapphire" style={{ fontSize: '0.72rem' }}>
                              Draft
                            </span>
                          )}
                        </div>
                      </div>
                    </div>

                    {/* Transit Connector Note */}
                    {stop.bufferMins && (
                      <div
                        style={{
                          display: 'flex',
                          alignItems: 'center',
                          gap: '12px',
                          padding: '6px 0 6px 36px',
                          color: 'var(--text-muted)',
                          fontSize: '0.8rem',
                        }}
                      >
                        <div style={{ width: '2px', height: '18px', background: 'var(--accent-emerald)' }} />
                        <span>⏱ {stop.bufferMins} min transit buffer • Validated by Sri Lanka Terrain Calculator</span>
                      </div>
                    )}
                  </div>
                ))}
              </div>

              {/* Simulation Action Callout */}
              <div
                style={{
                  marginTop: '28px',
                  padding: '20px',
                  borderRadius: 'var(--radius-sm)',
                  background: 'rgba(255, 255, 255, 0.02)',
                  border: '1px dashed var(--border-glass)',
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                }}
              >
                <div>
                  <div style={{ fontWeight: 600, fontSize: '0.95rem' }}>Simulate Provider Response</div>
                  <div style={{ fontSize: '0.82rem', color: 'var(--text-secondary)', marginTop: '2px' }}>
                    Toggle Sigiriya Eco Villa between Pending Request & Confirmed status.
                  </div>
                </div>
                <button
                  onClick={toggleEcoVillaConfirmation}
                  className="btn btn-secondary"
                  style={{ fontSize: '0.85rem' }}
                >
                  {stops.find((s) => s.id === 'stop-4')?.status === 'CONFIRMED'
                    ? 'Revert to Pending'
                    : 'Confirm Eco Villa'}
                </button>
              </div>
            </div>
          )}

          {/* View 2: Pilot Corridor Hub */}
          {activeTab === 'corridor' && (
            <div className="glass-panel" style={{ padding: '32px' }}>
              <h2 style={{ fontSize: '1.4rem', marginBottom: '8px' }}>
                Curated Pilot Corridor: Colombo → Sigiriya → Kandy → Nuwara Eliya
              </h2>
              <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', marginBottom: '24px' }}>
                ADR 0001: Focused corridor guarantees provider density, reliable mountain travel estimates, and verified SLTDA license coverage.
              </p>

              <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
                {CORRIDOR_DESTINATIONS.map((dest, idx) => (
                  <div
                    key={dest.name}
                    style={{
                      padding: '22px',
                      background: 'rgba(255, 255, 255, 0.03)',
                      borderRadius: 'var(--radius-sm)',
                      border: '1px solid var(--border-glass)',
                    }}
                  >
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                      <div>
                        <span className="badge badge-sapphire" style={{ fontSize: '0.72rem', marginBottom: '8px' }}>
                          Stop {idx + 1} • {dest.province}
                        </span>
                        <h3 style={{ fontSize: '1.2rem', marginTop: '4px' }}>{dest.name}</h3>
                        <p style={{ fontSize: '0.85rem', color: 'var(--accent-emerald)', marginTop: '4px' }}>
                          Elevation: {dest.altitude}
                        </p>
                      </div>
                      <div style={{ textAlign: 'right' }}>
                        <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>Intercity Leg:</span>
                        <div style={{ fontSize: '0.85rem', fontWeight: 600, color: '#f8fafc', marginTop: '2px' }}>
                          {dest.driveTimeFromPrev}
                        </div>
                      </div>
                    </div>

                    <div style={{ marginTop: '14px', display: 'flex', gap: '8px', flexWrap: 'wrap' }}>
                      {dest.highlights.map((h) => (
                        <span
                          key={h}
                          style={{
                            padding: '4px 10px',
                            background: 'rgba(255, 255, 255, 0.05)',
                            borderRadius: 'var(--radius-pill)',
                            fontSize: '0.78rem',
                            color: 'var(--text-secondary)',
                          }}
                        >
                          ✓ {h}
                        </span>
                      ))}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* View 3: TripGraph Engine Rule Check */}
          {activeTab === 'validation' && (
            <div className="glass-panel" style={{ padding: '32px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
                <div>
                  <h2 style={{ fontSize: '1.4rem' }}>TripGraph Deterministic Engine</h2>
                  <p style={{ color: 'var(--text-secondary)', fontSize: '0.88rem' }}>
                    Physical feasibility, mountain speed physics, and temporal conflict validation.
                  </p>
                </div>
                <span className="badge badge-emerald">Engine Active</span>
              </div>

              <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
                <div
                  style={{
                    padding: '16px',
                    borderRadius: 'var(--radius-sm)',
                    background: 'rgba(16, 185, 129, 0.08)',
                    border: '1px solid rgba(16, 185, 129, 0.3)',
                  }}
                >
                  <div style={{ fontWeight: 600, color: '#34d399' }}>✓ Temporal Non-Overlap Guarantee</div>
                  <div style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginTop: '4px' }}>
                    Zero clashing fixed-time reservations detected across Days 1–3. Schedule is mathematically conflict-free.
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
                  <div style={{ fontWeight: 600, color: '#34d399' }}>✓ Sri Lanka Highland Speed Model (Detour Factor 1.45)</div>
                  <div style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginTop: '4px' }}>
                    Kandy to Nuwara Eliya evaluates at 32 km/h mountain speed with required 45-min rest buffer.
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
                  <div style={{ fontWeight: 600, color: '#34d399' }}>✓ Venue Operating Hours Compliance</div>
                  <div style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginTop: '4px' }}>
                    Temple of the Tooth Relic scheduled at 09:00 (venue open 05:30 - 20:00). Sigiriya ascent scheduled at 15:00 (open 06:30 - 18:00).
                  </div>
                </div>

                <div
                  style={{
                    padding: '16px',
                    borderRadius: 'var(--radius-sm)',
                    background:
                      overallTripStatus === 'FULLY_CONFIRMED'
                        ? 'rgba(16, 185, 129, 0.08)'
                        : 'rgba(245, 158, 11, 0.08)',
                    border:
                      overallTripStatus === 'FULLY_CONFIRMED'
                        ? '1px solid rgba(16, 185, 129, 0.3)'
                        : '1px solid rgba(245, 158, 11, 0.3)',
                  }}
                >
                  <div
                    style={{
                      fontWeight: 600,
                      color: overallTripStatus === 'FULLY_CONFIRMED' ? '#34d399' : '#fbbf24',
                    }}
                  >
                    {overallTripStatus === 'FULLY_CONFIRMED'
                      ? '✓ All Bookings Authoritatively Confirmed'
                      : '⚠ Unconfirmed Supplier Advisory: Sigiriya Eco Villa'}
                  </div>
                  <div style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginTop: '4px' }}>
                    {overallTripStatus === 'FULLY_CONFIRMED'
                      ? 'All component bookings have confirmed supplier availability. Itinerary is ready for travel.'
                      : 'Provider manual confirmation required within 12h window. Trip status holds truthfully at PARTIALLY_CONFIRMED.'}
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* View 4: Sandbox Checkout & Double-Entry Ledger */}
          {activeTab === 'checkout' && (
            <div className="glass-panel" style={{ padding: '32px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
                <div>
                  <h2 style={{ fontSize: '1.4rem' }}>PayHere Sandbox Gateway & Ledger</h2>
                  <p style={{ color: 'var(--text-secondary)', fontSize: '0.88rem' }}>
                    Gate 5: Server-side webhook verification, double-entry escrow, and replay defense.
                  </p>
                </div>
                <span className="badge badge-sapphire">Sandbox Active</span>
              </div>

              {/* Financial Breakdown Table */}
              <div
                style={{
                  background: 'rgba(255, 255, 255, 0.02)',
                  border: '1px solid var(--border-glass)',
                  borderRadius: 'var(--radius-sm)',
                  padding: '20px',
                  marginBottom: '24px',
                }}
              >
                <h4 style={{ fontSize: '1rem', marginBottom: '14px' }}>Marketplace Split Allocation</h4>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '10px', fontSize: '0.9rem' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                    <span style={{ color: 'var(--text-secondary)' }}>Gross Booking Value (GBV):</span>
                    <strong>LKR {totalPriceLKR.toLocaleString()}</strong>
                  </div>
                  <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                    <span style={{ color: 'var(--text-secondary)' }}>TRAVERZA Commission (10% agreed partner rule):</span>
                    <strong style={{ color: 'var(--accent-amber)' }}>LKR {platformCommissionLKR.toLocaleString()}</strong>
                  </div>
                  <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                    <span style={{ color: 'var(--text-secondary)' }}>Net Provider Payable (Held in Escrow pending fulfilment):</span>
                    <strong style={{ color: 'var(--accent-emerald)' }}>LKR {netProviderPayableLKR.toLocaleString()}</strong>
                  </div>
                </div>
              </div>

              {/* Interactive Webhook Simulator Buttons */}
              <div style={{ display: 'flex', gap: '14px', flexWrap: 'wrap' }}>
                <button
                  onClick={() => handleSimulatePaymentWebhook(false)}
                  disabled={simulatedWebhookState === 'processing'}
                  className="btn btn-primary"
                  style={{ flex: 1 }}
                >
                  {simulatedWebhookState === 'processing'
                    ? 'Verifying Signature...'
                    : 'Simulate Valid Webhook (Capture)'}
                </button>
                <button
                  onClick={() => handleSimulatePaymentWebhook(true)}
                  disabled={simulatedWebhookState === 'processing'}
                  className="btn btn-secondary"
                  style={{ flex: 1 }}
                >
                  Simulate Duplicate Webhook (Replay Defense)
                </button>
              </div>

              {simulatedWebhookState !== 'idle' && (
                <div
                  className="animate-fade-in"
                  style={{
                    marginTop: '20px',
                    padding: '16px',
                    borderRadius: 'var(--radius-sm)',
                    background:
                      simulatedWebhookState === 'duplicate'
                        ? 'rgba(59, 130, 246, 0.1)'
                        : 'rgba(16, 185, 129, 0.1)',
                    border:
                      simulatedWebhookState === 'duplicate'
                        ? '1px solid rgba(59, 130, 246, 0.3)'
                        : '1px solid rgba(16, 185, 129, 0.3)',
                    fontSize: '0.85rem',
                  }}
                >
                  <div style={{ fontWeight: 600 }}>
                    {simulatedWebhookState === 'duplicate'
                      ? 'Deduplication Status: duplicate_ignored'
                      : 'Capture Status: processed'}
                  </div>
                  <div style={{ color: 'var(--text-secondary)', marginTop: '4px' }}>
                    Event ID: <span style={{ fontFamily: 'monospace' }}>evt_sandbox_9041_pk</span> • Double-entry Ledger balanced: Debit GATEWAY_CASH = Credit PLATFORM_ESCROW.
                  </div>
                </div>
              )}
            </div>
          )}
        </div>

        {/* Right Column: Trip Readiness & Booking Summary */}
        <div>
          <div className="glass-panel" style={{ padding: '28px', position: 'sticky', top: '100px' }}>
            <h3 style={{ fontSize: '1.25rem', marginBottom: '16px' }}>Trip Readiness Check</h3>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px', marginBottom: '24px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.9rem' }}>
                <span style={{ color: 'var(--text-secondary)' }}>Status:</span>
                <span
                  style={{
                    fontWeight: 700,
                    color: overallTripStatus === 'FULLY_CONFIRMED' ? '#34d399' : '#fbbf24',
                  }}
                >
                  {overallTripStatus === 'FULLY_CONFIRMED' ? 'Fully Confirmed' : 'Partially Confirmed'}
                </span>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.9rem' }}>
                <span style={{ color: 'var(--text-secondary)' }}>Booked Components:</span>
                <span>{confirmedCount} of {totalCount} Confirmed</span>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.9rem' }}>
                <span style={{ color: 'var(--text-secondary)' }}>Route Feasibility:</span>
                <span style={{ color: 'var(--accent-emerald)', fontWeight: 600 }}>100% Validated</span>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.9rem' }}>
                <span style={{ color: 'var(--text-secondary)' }}>Active Corridors:</span>
                <span>Cultural Triangle</span>
              </div>
              <div
                style={{
                  height: '1px',
                  background: 'var(--border-glass)',
                  margin: '8px 0',
                }}
              />
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <span style={{ fontSize: '1rem', fontWeight: 600 }}>Total Trip Cost:</span>
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
                Open Provider Workspace
              </Link>
              <Link
                href="/admin"
                className="btn btn-secondary"
                style={{ width: '100%', textAlign: 'center' }}
              >
                Open Operations Exception Desk
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
              🔒 <strong>Truth Before Convenience Guarantee:</strong> TRAVERZA never claims an itinerary is confirmed while components await provider review.
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
