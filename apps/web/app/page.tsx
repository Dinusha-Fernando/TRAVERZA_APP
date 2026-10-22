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
  lat?: number;
  lng?: number;
  altitude?: string;
  mapQuery?: string;
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
    lat: 7.1808,
    lng: 79.8841,
    altitude: '8m',
    mapQuery: 'Bandaranaike+International+Airport+Katunayake+Sri+Lanka',
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
    lat: 7.4863,
    lng: 80.3623,
    altitude: '116m',
    mapQuery: 'Kurunegala+Central+Expressway+Interchange+Sri+Lanka',
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
    lat: 7.9570,
    lng: 80.7603,
    altitude: '349m',
    mapQuery: 'Sigiriya+Rock+Fortress+Sri+Lanka',
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
    lat: 7.9525,
    lng: 80.7480,
    altitude: '195m',
    mapQuery: 'Water+Garden+Sigiriya+Resort+Sri+Lanka',
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
    lat: 7.2936,
    lng: 80.6413,
    altitude: '500m',
    mapQuery: 'Temple+of+the+Sacred+Tooth+Relic+Kandy+Sri+Lanka',
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
  const [activeTab, setActiveTab] = useState<'timeline' | 'map' | 'corridor' | 'validation' | 'checkout' | 'autopilot'>('timeline');
  const [mapMode, setMapMode] = useState<'k' | 'p' | 'm'>('k'); // k = satellite, p = terrain, m = roadmap
  const [selectedMapStopId, setSelectedMapStopId] = useState<string>('stop-3');
  const [simulatedWebhookState, setSimulatedWebhookState] = useState<'idle' | 'processing' | 'captured' | 'duplicate'>('idle');
  const [showNotification, setShowNotification] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState('');

  // TRAVERZA 2.0 Journey Autopilot Simulation State
  const [autopilotDisruption, setAutopilotDisruption] = useState<'none' | 'flight_delay' | 'driver_breakdown' | 'mountain_weather'>('none');
  const [autopilotStep, setAutopilotStep] = useState<number>(0);
  const [autopilotAuthorized, setAutopilotAuthorized] = useState<boolean>(false);


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

  // Filtered stops for search query
  const filteredStops = searchQuery.trim()
    ? stops.filter(
        (s) =>
          s.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
          s.location.toLowerCase().includes(searchQuery.toLowerCase()) ||
          s.provider.toLowerCase().includes(searchQuery.toLowerCase()) ||
          s.category.toLowerCase().includes(searchQuery.toLowerCase())
      )
    : stops;

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

  const triggerAutopilotDisruption = (type: 'flight_delay' | 'driver_breakdown' | 'mountain_weather') => {
    setAutopilotDisruption(type);
    setAutopilotStep(3); // Ingested (Step 1), Assessed (Step 2), Proposed (Step 3)
    setAutopilotAuthorized(false);
    const msg =
      type === 'flight_delay'
        ? '⚡ Autopilot Alert: Flight UL-504 delay (+90m) ingested from SriLankan Airlines live feed. Proposal generated.'
        : type === 'driver_breakdown'
        ? '⚡ Autopilot Alert: Assigned chauffeur breakdown reported near Kadawatha. Emergency backup dispatch prepared.'
        : '⚡ Autopilot Alert: DMC heavy rain advisory on Ramboda pass. Highland transit buffer (+45m) proposed.';
    setShowNotification(msg);
    setTimeout(() => setShowNotification(null), 6000);
  };

  const handleAuthorizeAutopilot = (decision: 'APPROVE' | 'REJECT') => {
    if (decision === 'APPROVE') {
      setAutopilotStep(6); // Executed (Step 5) & Verified (Step 6)
      setAutopilotAuthorized(true);
      if (autopilotDisruption === 'flight_delay') {
        setStops((prev) =>
          prev.map((s) => {
            if (s.id === 'stop-1') return { ...s, time: '10:30 - 11:30' };
            if (s.id === 'stop-2') return { ...s, time: '12:00 - 15:30' };
            return s;
          })
        );
      }
      setShowNotification('✓ Autopilot Proposal Authorized & Executed! TripGraph mathematically verified 0 hard errors.');
    } else {
      setAutopilotStep(0);
      setAutopilotDisruption('none');
      setAutopilotAuthorized(false);
      setShowNotification('Autopilot Proposal Rejected by User. Original itinerary preserved.');
    }
    setTimeout(() => setShowNotification(null), 6000);
  };

  const resetAutopilot = () => {
    setAutopilotDisruption('none');
    setAutopilotStep(0);
    setAutopilotAuthorized(false);
    setStops(INITIAL_STOPS);
    setShowNotification('Autopilot reset to baseline active monitoring.');
    setTimeout(() => setShowNotification(null), 4000);
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
            background: 'linear-gradient(180deg, var(--color-primary) 0%, var(--color-secondary) 100%)',
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
            marginBottom: '28px',
          }}
        >
          Discover Sri Lanka, plan realistic multi-day itineraries, book SLTDA-verified local services, and manage your entire journey with real-time transit validation.
        </p>

        {/* Interactive Search Bar */}
        <div
          style={{
            width: '100%',
            maxWidth: '680px',
            marginBottom: '16px',
            display: 'flex',
            alignItems: 'center',
            background: 'var(--color-surface)',
            border: '1.5px solid var(--color-border)',
            borderRadius: 'var(--radius-pill)',
            padding: '8px 16px',
            boxShadow: 'var(--shadow-card)',
            gap: '12px',
          }}
        >
          <span style={{ fontSize: '1.2rem' }}>🔍</span>
          <input
            type="text"
            placeholder="Search Sri Lanka destinations, stays and experiences (e.g., Sigiriya, Kandy)..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            style={{
              flex: 1,
              border: 'none',
              outline: 'none',
              background: 'transparent',
              fontSize: '0.95rem',
              color: 'var(--color-text)',
              fontFamily: 'inherit',
            }}
          />
          {searchQuery && (
            <button
              onClick={() => setSearchQuery('')}
              style={{
                background: 'none',
                border: 'none',
                color: 'var(--color-text-muted)',
                cursor: 'pointer',
                fontSize: '1rem',
              }}
            >
              ✕
            </button>
          )}
          <button
            onClick={() => setActiveTab('timeline')}
            className="btn btn-primary"
            style={{ padding: '8px 20px', fontSize: '0.9rem' }}
          >
            Search
          </button>
        </div>

        {/* Quick Destination Pills */}
        <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap', justifyContent: 'center', marginBottom: '28px' }}>
          {['Sigiriya', 'Kandy', 'Nuwara Eliya', 'Chauffeur', 'Eco Villa'].map((tag) => (
            <button
              key={tag}
              onClick={() => {
                setSearchQuery(tag);
                setActiveTab('timeline');
              }}
              style={{
                background: searchQuery === tag ? 'var(--color-sand)' : 'var(--color-surface)',
                border: '1px solid var(--color-border)',
                borderRadius: 'var(--radius-pill)',
                padding: '4px 12px',
                fontSize: '0.8rem',
                color: 'var(--color-primary)',
                fontWeight: 600,
                cursor: 'pointer',
              }}
            >
              {tag}
            </button>
          ))}
        </div>

        {/* Tab Controls */}
        <div style={{ display: 'flex', gap: '12px', flexWrap: 'wrap', justifyContent: 'center' }}>
          <button
            onClick={() => setActiveTab('timeline')}
            className={`btn ${activeTab === 'timeline' ? 'btn-primary' : 'btn-secondary'}`}
          >
            Trip Canvas Timeline
          </button>
          <button
            onClick={() => setActiveTab('map')}
            className={`btn ${activeTab === 'map' ? 'btn-primary' : 'btn-secondary'}`}
          >
            🗺️ Google Maps & Route
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
            onClick={() => setActiveTab('autopilot')}
            className={`btn ${activeTab === 'autopilot' ? 'btn-primary' : 'btn-secondary'}`}
            style={{
              background:
                activeTab === 'autopilot'
                  ? 'linear-gradient(135deg, #0284c7 0%, #0369a1 100%)'
                  : 'rgba(2, 132, 199, 0.12)',
              border: '1px solid rgba(2, 132, 199, 0.4)',
              color: activeTab === 'autopilot' ? '#ffffff' : '#38bdf8',
            }}
          >
            ⚡ Journey Autopilot 2.0
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
              {searchQuery && (
                <div
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    marginBottom: '16px',
                    padding: '10px 14px',
                    background: 'rgba(8, 126, 139, 0.1)',
                    border: '1px solid rgba(8, 126, 139, 0.3)',
                    borderRadius: 'var(--radius-sm)',
                  }}
                >
                  <span style={{ fontSize: '0.86rem', color: 'var(--color-primary)' }}>
                    Filtering stops by <strong>&ldquo;{searchQuery}&rdquo;</strong> ({filteredStops.length} result{filteredStops.length === 1 ? '' : 's'})
                  </span>
                  <button
                    onClick={() => setSearchQuery('')}
                    style={{
                      background: 'none',
                      border: 'none',
                      color: 'var(--color-secondary)',
                      fontSize: '0.8rem',
                      fontWeight: 700,
                      cursor: 'pointer',
                    }}
                  >
                    Clear Filter
                  </button>
                </div>
              )}

              {filteredStops.length === 0 ? (
                <div style={{ textAlign: 'center', padding: '36px 16px', color: 'var(--color-text-muted)' }}>
                  <p style={{ fontSize: '1.05rem', marginBottom: '8px' }}>No itinerary stops match &ldquo;{searchQuery}&rdquo;</p>
                  <button
                    onClick={() => setSearchQuery('')}
                    className="btn btn-secondary"
                    style={{ fontSize: '0.85rem' }}
                  >
                    Show All Stops
                  </button>
                </div>
              ) : (
                <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                  {filteredStops.map((stop) => (
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
            )}

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

          {/* View: Interactive Google Maps Route Canvas */}
          {activeTab === 'map' && (
            <div className="glass-panel" style={{ padding: '32px' }}>
              <div
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  marginBottom: '20px',
                  paddingBottom: '16px',
                  borderBottom: '1px solid var(--border-glass)',
                  flexWrap: 'wrap',
                  gap: '12px',
                }}
              >
                <div>
                  <h2 style={{ fontSize: '1.4rem' }}>Sri Lanka GPS Corridor & Google Maps Navigator</h2>
                  <p style={{ color: 'var(--text-secondary)', fontSize: '0.88rem' }}>
                    Live GPS coordinates, elevation profiles, and 1-click turn-by-turn navigation across the Colombo-Sigiriya-Kandy-Highlands corridor.
                  </p>
                </div>
                <a
                  href="https://www.google.com/maps/dir/?api=1&origin=Bandaranaike+International+Airport+Katunayake&destination=Sigiriya+Water+Garden+Eco+Resort&waypoints=Sigiriya+Rock+Fortress&travelmode=driving"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="btn btn-primary"
                  style={{ display: 'inline-flex', alignItems: 'center', gap: '8px', textDecoration: 'none' }}
                >
                  <span>📍</span> Open Entire Route on Google Maps
                </a>
              </div>

              {/* Map Layer Mode Toggles & Waypoint Quick Selector */}
              <div
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  marginBottom: '16px',
                  flexWrap: 'wrap',
                  gap: '12px',
                }}
              >
                <div style={{ display: 'flex', gap: '8px' }}>
                  <button
                    onClick={() => setMapMode('k')}
                    style={{
                      padding: '6px 14px',
                      borderRadius: 'var(--radius-pill)',
                      border: '1px solid var(--color-border)',
                      background: mapMode === 'k' ? 'var(--color-primary)' : 'var(--color-surface)',
                      color: mapMode === 'k' ? '#FFFFFF' : 'var(--color-text)',
                      fontSize: '0.82rem',
                      fontWeight: 600,
                      cursor: 'pointer',
                    }}
                  >
                    🛰️ Satellite View
                  </button>
                  <button
                    onClick={() => setMapMode('p')}
                    style={{
                      padding: '6px 14px',
                      borderRadius: 'var(--radius-pill)',
                      border: '1px solid var(--color-border)',
                      background: mapMode === 'p' ? 'var(--color-primary)' : 'var(--color-surface)',
                      color: mapMode === 'p' ? '#FFFFFF' : 'var(--color-text)',
                      fontSize: '0.82rem',
                      fontWeight: 600,
                      cursor: 'pointer',
                    }}
                  >
                    ⛰️ Highland Terrain
                  </button>
                  <button
                    onClick={() => setMapMode('m')}
                    style={{
                      padding: '6px 14px',
                      borderRadius: 'var(--radius-pill)',
                      border: '1px solid var(--color-border)',
                      background: mapMode === 'm' ? 'var(--color-primary)' : 'var(--color-surface)',
                      color: mapMode === 'm' ? '#FFFFFF' : 'var(--color-text)',
                      fontSize: '0.82rem',
                      fontWeight: 600,
                      cursor: 'pointer',
                    }}
                  >
                    🗺️ Highway Road Map
                  </button>
                </div>

                <span style={{ fontSize: '0.82rem', color: 'var(--text-muted)' }}>
                  Active Focus: <strong>{stops.find((s) => s.id === selectedMapStopId)?.title.split('(')[0]}</strong>
                </span>
              </div>

              {/* Responsive Embedded Google Map */}
              <div
                style={{
                  position: 'relative',
                  width: '100%',
                  height: '380px',
                  borderRadius: 'var(--radius-sm)',
                  overflow: 'hidden',
                  border: '1.5px solid var(--color-border)',
                  boxShadow: 'var(--shadow-card)',
                  marginBottom: '20px',
                }}
              >
                <iframe
                  title="Google Maps Sri Lanka Itinerary Route"
                  width="100%"
                  height="100%"
                  style={{ border: 0 }}
                  loading="lazy"
                  allowFullScreen
                  referrerPolicy="no-referrer-when-downgrade"
                  src={`https://maps.google.com/maps?q=${encodeURIComponent(
                    stops.find((s) => s.id === selectedMapStopId)?.mapQuery || 'Sigiriya+Rock+Fortress+Sri+Lanka'
                  )}&t=${mapMode}&z=13&ie=UTF8&iwloc=&output=embed`}
                />
              </div>

              {/* Stop Selector Carousel / Horizontal Pills */}
              <div style={{ display: 'flex', gap: '8px', overflowX: 'auto', paddingBottom: '12px', marginBottom: '24px' }}>
                {stops.map((stop) => {
                  const isSelected = stop.id === selectedMapStopId;
                  return (
                    <button
                      key={stop.id}
                      onClick={() => setSelectedMapStopId(stop.id)}
                      style={{
                        flexShrink: 0,
                        padding: '10px 14px',
                        borderRadius: 'var(--radius-sm)',
                        background: isSelected ? 'var(--color-primary)' : 'rgba(255, 255, 255, 0.04)',
                        color: isSelected ? '#FFFFFF' : 'var(--color-text)',
                        border: isSelected ? '1.5px solid var(--color-accent)' : '1px solid var(--border-glass)',
                        cursor: 'pointer',
                        textAlign: 'left',
                        transition: 'all 0.2s ease',
                      }}
                    >
                      <div style={{ fontSize: '0.72rem', color: isSelected ? 'var(--color-accent)' : 'var(--text-muted)', fontWeight: 700 }}>
                        DAY {stop.day} • {stop.category}
                      </div>
                      <div style={{ fontSize: '0.88rem', fontWeight: 700, marginTop: '2px', maxWidth: '200px', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                        {stop.title}
                      </div>
                      <div style={{ fontSize: '0.75rem', marginTop: '2px', opacity: 0.85 }}>
                        📍 {stop.altitude || 'Sea level'} • {stop.location}
                      </div>
                    </button>
                  );
                })}
              </div>

              {/* Selected Stop Geo Card with Google Maps Navigation Links */}
              {(() => {
                const activeStop = stops.find((s) => s.id === selectedMapStopId) || stops[2];
                return (
                  <div
                    style={{
                      background: 'rgba(255, 255, 255, 0.03)',
                      border: '1px solid var(--border-glass)',
                      borderRadius: 'var(--radius-sm)',
                      padding: '24px',
                      display: 'grid',
                      gridTemplateColumns: 'minmax(0, 1fr) auto',
                      gap: '20px',
                      alignItems: 'center',
                    }}
                  >
                    <div>
                      <div style={{ display: 'flex', gap: '8px', alignItems: 'center', marginBottom: '8px' }}>
                        <span className="badge badge-sapphire" style={{ fontSize: '0.75rem' }}>
                          Day {activeStop.day} • {activeStop.time}
                        </span>
                        <span className="badge badge-emerald" style={{ fontSize: '0.75rem' }}>
                          Altitude: {activeStop.altitude || 'Highland'}
                        </span>
                        {activeStop.lat && (
                          <span style={{ fontSize: '0.78rem', color: 'var(--text-muted)', fontFamily: 'monospace' }}>
                            {activeStop.lat.toFixed(4)}° N, {activeStop.lng?.toFixed(4)}° E
                          </span>
                        )}
                      </div>
                      <h3 style={{ fontSize: '1.25rem', marginBottom: '4px' }}>{activeStop.title}</h3>
                      <p style={{ color: 'var(--text-secondary)', fontSize: '0.88rem', marginBottom: '8px' }}>
                        {activeStop.location} • Provider: <strong>{activeStop.provider}</strong>
                      </p>
                      {activeStop.bufferMins && (
                        <div style={{ fontSize: '0.82rem', color: '#fbbf24', display: 'flex', alignItems: 'center', gap: '6px' }}>
                          <span>⏱</span>
                          <span>
                            {activeStop.bufferMins} min transit buffer applied by Sri Lanka Terrain Speed Model.
                          </span>
                        </div>
                      )}
                    </div>

                    <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', minWidth: '220px' }}>
                      <a
                        href={`https://www.google.com/maps/dir/?api=1&destination=${activeStop.lat || 7.9570},${activeStop.lng || 80.7603}&travelmode=driving`}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="btn btn-primary"
                        style={{ textAlign: 'center', textDecoration: 'none', fontSize: '0.85rem' }}
                      >
                        🚗 Navigate with Google Maps
                      </a>
                      <a
                        href={`https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(activeStop.mapQuery || activeStop.title)}`}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="btn btn-secondary"
                        style={{ textAlign: 'center', textDecoration: 'none', fontSize: '0.85rem' }}
                      >
                        🔍 Explore in Google Maps
                      </a>
                    </div>
                  </div>
                );
              })()}

              {/* Emergency Safe-Zones Layer */}
              <div
                style={{
                  marginTop: '24px',
                  padding: '20px',
                  borderRadius: 'var(--radius-sm)',
                  background: 'rgba(225, 29, 72, 0.06)',
                  border: '1px solid rgba(225, 29, 72, 0.25)',
                }}
              >
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <span style={{ fontSize: '1.2rem' }}>🛡️</span>
                    <div>
                      <div style={{ fontWeight: 700, fontSize: '0.95rem', color: '#f43f5e' }}>
                        Nearest Emergency GPS Facilities (Sigiriya Sector)
                      </div>
                      <div style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>
                        Instant Google Maps routes to verified tourist police stations and 24/7 general hospitals.
                      </div>
                    </div>
                  </div>
                </div>

                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: '12px' }}>
                  <div
                    style={{
                      background: 'rgba(255, 255, 255, 0.04)',
                      padding: '14px',
                      borderRadius: 'var(--radius-sm)',
                      display: 'flex',
                      justifyContent: 'space-between',
                      alignItems: 'center',
                    }}
                  >
                    <div>
                      <div style={{ fontWeight: 700, fontSize: '0.9rem' }}>Sigiriya Tourist Police Station</div>
                      <div style={{ fontSize: '0.78rem', color: 'var(--text-muted)' }}>2.1 km away • 5 min drive</div>
                    </div>
                    <a
                      href="https://www.google.com/maps/dir/?api=1&destination=7.9542,80.7554&travelmode=driving"
                      target="_blank"
                      rel="noopener noreferrer"
                      className="btn btn-secondary"
                      style={{ fontSize: '0.78rem', padding: '6px 12px', textDecoration: 'none' }}
                    >
                      Maps Route
                    </a>
                  </div>

                  <div
                    style={{
                      background: 'rgba(255, 255, 255, 0.04)',
                      padding: '14px',
                      borderRadius: 'var(--radius-sm)',
                      display: 'flex',
                      justifyContent: 'space-between',
                      alignItems: 'center',
                    }}
                  >
                    <div>
                      <div style={{ fontWeight: 700, fontSize: '0.9rem' }}>Dambulla Base General Hospital ER</div>
                      <div style={{ fontSize: '0.78rem', color: 'var(--text-muted)' }}>16.4 km away • 22 min drive</div>
                    </div>
                    <a
                      href="https://www.google.com/maps/dir/?api=1&destination=7.8731,80.6517&travelmode=driving"
                      target="_blank"
                      rel="noopener noreferrer"
                      className="btn btn-secondary"
                      style={{ fontSize: '0.78rem', padding: '6px 12px', textDecoration: 'none' }}
                    >
                      Maps Route
                    </a>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* View 3: Pilot Corridor Hub */}
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

          {/* View 5: TRAVERZA 2.0 Journey Autopilot Panel */}
          {activeTab === 'autopilot' && (
            <div className="glass-panel" style={{ padding: '32px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px', flexWrap: 'wrap', gap: '12px' }}>
                <div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '6px' }}>
                    <span className="badge badge-sapphire" style={{ fontSize: '0.75rem' }}>
                      TRAVERZA 2.0 Flagship Innovation
                    </span>
                    <span className="badge badge-emerald" style={{ fontSize: '0.75rem' }}>
                      Active Autopilot Engine {autopilotStep > 0 ? `• Stage ${autopilotStep}/6` : '• Standby'}
                    </span>
                  </div>
                  <h2 style={{ fontSize: '1.5rem', background: 'linear-gradient(135deg, #38bdf8 0%, #0284c7 100%)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>
                    Journey Autopilot™ — Disruption Recovery & Adaptation
                  </h2>
                  <p style={{ color: 'var(--text-secondary)', fontSize: '0.88rem', marginTop: '4px' }}>
                    A closed-loop coordination engine: <strong>Observe → Assess → Propose → Authorize → Execute → Verify</strong>.
                  </p>
                </div>
              </div>

              {/* Simulation Action Triggers */}
              <div
                style={{
                  background: 'rgba(2, 132, 199, 0.08)',
                  border: '1px solid rgba(2, 132, 199, 0.25)',
                  borderRadius: 'var(--radius-sm)',
                  padding: '20px',
                  marginBottom: '24px',
                }}
              >
                <div style={{ fontSize: '0.82rem', fontWeight: 700, color: '#38bdf8', letterSpacing: '0.05em', textTransform: 'uppercase', marginBottom: '12px' }}>
                  Interactive Disruption Sandbox
                </div>
                <div style={{ display: 'flex', gap: '10px', flexWrap: 'wrap' }}>
                  <button
                    onClick={() => triggerAutopilotDisruption('flight_delay')}
                    className="btn btn-secondary"
                    style={{
                      fontSize: '0.84rem',
                      padding: '8px 14px',
                      background: autopilotDisruption === 'flight_delay' ? 'rgba(56, 189, 248, 0.25)' : undefined,
                      borderColor: autopilotDisruption === 'flight_delay' ? '#38bdf8' : undefined,
                    }}
                  >
                    ✈️ Simulate 90m Flight Delay (UL-504)
                  </button>
                  <button
                    onClick={() => triggerAutopilotDisruption('driver_breakdown')}
                    className="btn btn-secondary"
                    style={{
                      fontSize: '0.84rem',
                      padding: '8px 14px',
                      background: autopilotDisruption === 'driver_breakdown' ? 'rgba(239, 68, 68, 0.25)' : undefined,
                      borderColor: autopilotDisruption === 'driver_breakdown' ? '#ef4444' : undefined,
                    }}
                  >
                    🚗 Simulate Driver Breakdown
                  </button>
                  <button
                    onClick={() => triggerAutopilotDisruption('mountain_weather')}
                    className="btn btn-secondary"
                    style={{
                      fontSize: '0.84rem',
                      padding: '8px 14px',
                      background: autopilotDisruption === 'mountain_weather' ? 'rgba(245, 158, 11, 0.25)' : undefined,
                      borderColor: autopilotDisruption === 'mountain_weather' ? '#f59e0b' : undefined,
                    }}
                  >
                    🌧️ Highland Roadwork Advisory (+45m)
                  </button>
                  {autopilotDisruption !== 'none' && (
                    <button
                      onClick={resetAutopilot}
                      className="btn"
                      style={{
                        fontSize: '0.84rem',
                        padding: '8px 14px',
                        background: 'rgba(255, 255, 255, 0.1)',
                        color: 'var(--text-muted)',
                      }}
                    >
                      ↺ Reset
                    </button>
                  )}
                </div>
              </div>

              {/* Autopilot 6-Step Loop Live Tracker */}
              {autopilotDisruption === 'none' ? (
                <div
                  style={{
                    padding: '36px',
                    textAlign: 'center',
                    background: 'rgba(255, 255, 255, 0.02)',
                    borderRadius: 'var(--radius-sm)',
                    border: '1px dashed var(--border-glass)',
                  }}
                >
                  <div style={{ fontSize: '2.4rem', marginBottom: '12px' }}>🛡️</div>
                  <h3 style={{ fontSize: '1.15rem', color: '#f8fafc' }}>Active Journey Autopilot Monitoring</h3>
                  <p style={{ color: 'var(--text-secondary)', fontSize: '0.88rem', maxWidth: '520px', margin: '8px auto 0' }}>
                    Flight radar feeds, Sri Lanka Disaster Management Centre advisories, and chauffeur dispatch channels are connected. Click a disruption scenario above to see the 6-step recovery loop in action.
                  </p>
                </div>
              ) : (
                <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                  {/* Step 1: OBSERVE */}
                  <div
                    style={{
                      padding: '18px',
                      borderRadius: 'var(--radius-sm)',
                      background: 'rgba(56, 189, 248, 0.08)',
                      border: '1px solid rgba(56, 189, 248, 0.3)',
                    }}
                  >
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
                      <div style={{ fontWeight: 700, color: '#38bdf8', fontSize: '0.9rem' }}>
                        1. OBSERVE — Verified Event Ingested
                      </div>
                      <span className="badge badge-sapphire" style={{ fontSize: '0.72rem' }}>
                        Freshness: 0s ago (Verified)
                      </span>
                    </div>
                    <div style={{ fontSize: '0.88rem', color: '#f1f5f9' }}>
                      {autopilotDisruption === 'flight_delay' && (
                        <>
                          <strong>Flight UL-504 (London Heathrow → Colombo)</strong> delayed by 90 minutes.
                          <div style={{ fontSize: '0.8rem', color: 'var(--text-secondary)', marginTop: '4px' }}>
                            Source: SriLankan Airlines Live Radar Feed • Observed at: 2026-10-24 07:15 UTC • Original ETA: 10:00 → Revised ETA: 11:30.
                          </div>
                        </>
                      )}
                      {autopilotDisruption === 'driver_breakdown' && (
                        <>
                          <strong>Chauffeur Fleet #LK-102 (Toyota Prado)</strong> reported mechanical issue near Kadawatha interchange.
                          <div style={{ fontSize: '0.8rem', color: 'var(--text-secondary)', marginTop: '4px' }}>
                            Source: Ceylon Chauffeurs Guild Hotline • Severity: CRITICAL • 3h 15m prior to CMB pickup.
                          </div>
                        </>
                      )}
                      {autopilotDisruption === 'mountain_weather' && (
                        <>
                          <strong>DMC Weather & Roadwork Advisory</strong> active on A5 mountain route near Ramboda Pass.
                          <div style={{ fontSize: '0.8rem', color: 'var(--text-secondary)', marginTop: '4px' }}>
                            Source: Disaster Management Centre (DMC) • Heavy rainfall and resurfacing delay (+45m).
                          </div>
                        </>
                      )}
                    </div>
                  </div>

                  {/* Step 2: ASSESS */}
                  <div
                    style={{
                      padding: '18px',
                      borderRadius: 'var(--radius-sm)',
                      background: 'rgba(245, 158, 11, 0.08)',
                      border: '1px solid rgba(245, 158, 11, 0.3)',
                    }}
                  >
                    <div style={{ fontWeight: 700, color: '#fbbf24', fontSize: '0.9rem', marginBottom: '8px' }}>
                      2. ASSESS — Downstream Impact Analysis
                    </div>
                    <div style={{ fontSize: '0.88rem', color: '#f1f5f9' }}>
                      {autopilotDisruption === 'flight_delay' && (
                        <>
                          Downstream clash detected: Airport Chauffeur Transfer (Fleet #LK-402) scheduled pickup at 10:30 is <strong>impossible</strong> with 11:30 landing.
                          <div style={{ fontSize: '0.8rem', color: 'var(--text-secondary)', marginTop: '4px' }}>
                            Buffer deficit: -60 minutes. Subsequent Sigiriya Eco Villa 18:30 check-in remains feasible if pickup shifts to 12:00.
                          </div>
                        </>
                      )}
                      {autopilotDisruption === 'driver_breakdown' && (
                        <>
                          Critical connection severed: Day 1 CMB Airport to Sigiriya transit cannot proceed without replacement vehicle.
                          <div style={{ fontSize: '0.8rem', color: 'var(--text-secondary)', marginTop: '4px' }}>
                            Depot check: Negombo fleet backup depot has certified Toyota Prado #LK-902 on standby (18m from terminal).
                          </div>
                        </>
                      )}
                      {autopilotDisruption === 'mountain_weather' && (
                        <>
                          Highland transit buffer deficit: Current schedule has only 20-min buffer between Kandy and Nuwara Eliya.
                          <div style={{ fontSize: '0.8rem', color: 'var(--text-secondary)', marginTop: '4px' }}>
                            TripGraph constraint: 32 km/h highland road speed requires +45m additional buffer to prevent dusk driving.
                          </div>
                        </>
                      )}
                    </div>
                  </div>

                  {/* Step 3: PROPOSE */}
                  <div
                    style={{
                      padding: '18px',
                      borderRadius: 'var(--radius-sm)',
                      background: 'rgba(99, 102, 241, 0.08)',
                      border: '1px solid rgba(99, 102, 241, 0.3)',
                    }}
                  >
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
                      <div style={{ fontWeight: 700, color: '#818cf8', fontSize: '0.9rem' }}>
                        3. PROPOSE — Candidate Resolution with Deltas
                      </div>
                      <span className="badge badge-sapphire" style={{ fontSize: '0.72rem' }}>
                        Confidence: 98%
                      </span>
                    </div>
                    <div style={{ fontSize: '0.88rem', color: '#f1f5f9' }}>
                      {autopilotDisruption === 'flight_delay' && (
                        <div>
                          <strong>Proposed Action:</strong> Shift Chauffeur Pickup from 10:30 to 12:00 (preserving 30m customs clearance buffer).
                          <div style={{ display: 'flex', gap: '16px', marginTop: '8px', fontSize: '0.85rem' }}>
                            <div>Timing Delta: <strong style={{ color: '#fbbf24' }}>+90 mins</strong></div>
                            <div>Cost Delta: <strong style={{ color: '#34d399' }}>LKR 0 (Contracted)</strong></div>
                            <div>Downstream Safety: <strong style={{ color: '#34d399' }}>Feasible</strong></div>
                          </div>
                        </div>
                      )}
                      {autopilotDisruption === 'driver_breakdown' && (
                        <div>
                          <strong>Proposed Action:</strong> Dispatch Negombo Depot backup chauffeur (Fleet #LK-902). Arrival at CMB in 35 mins.
                          <div style={{ display: 'flex', gap: '16px', marginTop: '8px', fontSize: '0.85rem' }}>
                            <div>Timing Delta: <strong style={{ color: '#34d399' }}>0 mins delay</strong></div>
                            <div>Cost Delta: <strong style={{ color: '#34d399' }}>LKR 0 (Fleet Guarantee)</strong></div>
                            <div>Provider Lic: <strong>SLTDA/CG/2026/102</strong></div>
                          </div>
                        </div>
                      )}
                      {autopilotDisruption === 'mountain_weather' && (
                        <div>
                          <strong>Proposed Action:</strong> Depart Kandy 30m earlier and inject 45-minute mountain transit buffer before tea factory.
                          <div style={{ display: 'flex', gap: '16px', marginTop: '8px', fontSize: '0.85rem' }}>
                            <div>Buffer Added: <strong style={{ color: '#38bdf8' }}>+45 mins</strong></div>
                            <div>Cost Delta: <strong style={{ color: '#34d399' }}>LKR 0</strong></div>
                            <div>Pacing: <strong>Balanced</strong></div>
                          </div>
                        </div>
                      )}
                    </div>
                  </div>

                  {/* Step 4: AUTHORIZE */}
                  <div
                    style={{
                      padding: '18px',
                      borderRadius: 'var(--radius-sm)',
                      background: autopilotAuthorized ? 'rgba(16, 185, 129, 0.08)' : 'rgba(239, 68, 68, 0.08)',
                      border: autopilotAuthorized ? '1px solid rgba(16, 185, 129, 0.3)' : '1px solid rgba(239, 68, 68, 0.3)',
                    }}
                  >
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
                      <div style={{ fontWeight: 700, color: autopilotAuthorized ? '#34d399' : '#f87171', fontSize: '0.9rem' }}>
                        4. AUTHORIZE — Non-Negotiable Human Gate
                      </div>
                      <span className={`badge ${autopilotAuthorized ? 'badge-emerald' : 'badge-amber'}`} style={{ fontSize: '0.72rem' }}>
                        {autopilotAuthorized ? 'Authorized by Traveller' : 'Pending Authorization'}
                      </span>
                    </div>
                    <div style={{ fontSize: '0.84rem', color: 'var(--text-secondary)', marginBottom: '14px' }}>
                      Safety Rule: AI may suggest and explain. Consequential itinerary modifications require explicit traveller or operator confirmation.
                    </div>
                    {!autopilotAuthorized ? (
                      <div style={{ display: 'flex', gap: '12px' }}>
                        <button
                          onClick={() => handleAuthorizeAutopilot('APPROVE')}
                          className="btn btn-primary"
                          style={{ flex: 1, padding: '10px 16px', fontSize: '0.88rem' }}
                        >
                          ✓ Approve Adaptation & Update Timeline
                        </button>
                        <button
                          onClick={() => handleAuthorizeAutopilot('REJECT')}
                          className="btn btn-secondary"
                          style={{ flex: 1, padding: '10px 16px', fontSize: '0.88rem' }}
                        >
                          ✕ Reject (Keep Original)
                        </button>
                      </div>
                    ) : (
                      <div style={{ fontSize: '0.86rem', color: '#34d399', fontWeight: 600 }}>
                        ✓ Authorization confirmed. Proposal unlocked for execution.
                      </div>
                    )}
                  </div>

                  {/* Step 5 & 6: EXECUTE & VERIFY (When Authorized) */}
                  {autopilotAuthorized && (
                    <div
                      className="animate-fade-in"
                      style={{
                        padding: '18px',
                        borderRadius: 'var(--radius-sm)',
                        background: 'rgba(16, 185, 129, 0.12)',
                        border: '1px solid rgba(16, 185, 129, 0.4)',
                      }}
                    >
                      <div style={{ fontWeight: 700, color: '#34d399', fontSize: '0.9rem', marginBottom: '8px' }}>
                        5. EXECUTE & 6. VERIFY — Idempotent Mutation & TripGraph Check
                      </div>
                      <div style={{ fontSize: '0.86rem', color: '#f1f5f9', display: 'flex', flexDirection: 'column', gap: '6px' }}>
                        <div>✓ Itinerary items updated: Airport Chauffeur transfer rescheduled to 12:00 - 15:30.</div>
                        <div>✓ Provider notification dispatched: Ceylon Chauffeurs Guild received automated dispatch token.</div>
                        <div>✓ TripGraph validation result: <strong>0 hard errors</strong>. Temporal sequence & buffer verified.</div>
                        <div>✓ Append-only audit record saved: Actor ID #traveller-9041 logged with IP and reason.</div>
                      </div>
                    </div>
                  )}
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
