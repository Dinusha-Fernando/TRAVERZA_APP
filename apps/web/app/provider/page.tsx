'use client';

import { useState } from 'react';
import Link from 'next/link';

interface BookingRequest {
  id: string;
  tripId: string;
  traveler: string;
  service: string;
  date: string;
  timeSlot: string;
  guests: number;
  amountLKR: number;
  expiresInMinutes: number;
  status: 'PENDING' | 'ACCEPTED' | 'DECLINED';
}

interface ProviderDoc {
  id: string;
  type: string;
  number: string;
  expiry: string;
  status: 'APPROVED' | 'PENDING' | 'EXPIRED';
  notes: string;
}

const INITIAL_REQUESTS: BookingRequest[] = [
  {
    id: 'req-9801',
    tripId: 'TRIP-LK-2026-9041',
    traveler: 'Dinusha & Family (UK)',
    service: 'Sigiriya Water Garden Eco Villa (Deluxe Chalet)',
    date: '24 Oct 2026',
    timeSlot: 'Check-in 18:30',
    guests: 2,
    amountLKR: 38000,
    expiresInMinutes: 702,
    status: 'PENDING',
  },
  {
    id: 'req-9802',
    tripId: 'TRIP-LK-2026-8812',
    traveler: 'Marcus Vance (Australia)',
    service: 'Kandy Lake View Heritage Room',
    date: '26 Oct 2026',
    timeSlot: 'Check-in 14:00',
    guests: 1,
    amountLKR: 24500,
    expiresInMinutes: 410,
    status: 'PENDING',
  },
  {
    id: 'req-9803',
    tripId: 'TRIP-LK-2026-8409',
    traveler: 'Elena Rostova (Germany)',
    service: 'Cultural Triangle Chauffeur Guide (Toyota KDH)',
    date: '28 Oct 2026',
    timeSlot: '08:00 Full Day',
    guests: 3,
    amountLKR: 22000,
    expiresInMinutes: 890,
    status: 'ACCEPTED',
  },
];

const INITIAL_DOCS: ProviderDoc[] = [
  {
    id: 'doc-1',
    type: 'SLTDA Tourism License',
    number: 'SLTDA/SQ/2026/089',
    expiry: '31 Dec 2026',
    status: 'APPROVED',
    notes: 'Verified against SLTDA active registry',
  },
  {
    id: 'doc-2',
    type: 'Business Registration (BR)',
    number: 'PV-0018442',
    expiry: 'Permanent',
    status: 'APPROVED',
    notes: 'Company Registrar corporate check passed',
  },
  {
    id: 'doc-3',
    type: 'Public Commercial Liability Insurance',
    number: 'INS-SL-88401',
    expiry: '15 Jan 2027',
    status: 'APPROVED',
    notes: 'Covers LKR 5,000,000 passenger/guest indemnity',
  },
];

interface ProviderPackage {
  id: string;
  title: string;
  type: 'OPERATOR_PACKAGE' | 'ITINERARY_TEMPLATE';
  duration: string;
  priceBasis: string;
  priceLKR: number;
  status: 'PUBLISHED' | 'IN_REVIEW' | 'DRAFT' | 'CHANGES_REQUESTED';
  corridor: string;
  version: number;
  sltdaLicense: string;
}

const INITIAL_PACKAGES: ProviderPackage[] = [
  {
    id: 'pkg-1',
    title: '3-Day Cultural Triangle Signature Escape',
    type: 'OPERATOR_PACKAGE',
    duration: '3 Days / 2 Nights',
    priceBasis: 'PER_PERSON (Bundled)',
    priceLKR: 68500,
    status: 'PUBLISHED',
    corridor: 'Colombo · Sigiriya · Kandy · Nuwara Eliya',
    version: 1,
    sltdaLicense: 'SLTDA/SQA/2026/044',
  },
  {
    id: 'pkg-2',
    title: '4-Day Heritage & Minneriya Safari Tour',
    type: 'OPERATOR_PACKAGE',
    duration: '4 Days / 3 Nights',
    priceBasis: 'PER_PERSON (Bundled)',
    priceLKR: 94000,
    status: 'IN_REVIEW',
    corridor: 'Sigiriya · Polonnaruwa · Minneriya',
    version: 2,
    sltdaLicense: 'SLTDA/SQA/2026/108',
  },
];

export default function ProviderPortalPage() {
  const [requests, setRequests] = useState<BookingRequest[]>(INITIAL_REQUESTS);
  const [docs, setDocs] = useState<ProviderDoc[]>(INITIAL_DOCS);
  const [packages, setPackages] = useState<ProviderPackage[]>(INITIAL_PACKAGES);
  const [activeTab, setActiveTab] = useState<'inbox' | 'compliance' | 'finance' | 'packages'>('inbox');
  const [notification, setNotification] = useState<string | null>(null);
  const [newDocType, setNewDocType] = useState('Vehicle Fleet Commercial Permit');
  const [newDocNumber, setNewDocNumber] = useState('');
  const [showDocModal, setShowDocModal] = useState(false);
  const [showPackageModal, setShowPackageModal] = useState(false);
  const [pkgTitle, setPkgTitle] = useState('');
  const [pkgType, setPkgType] = useState<'OPERATOR_PACKAGE' | 'ITINERARY_TEMPLATE'>('OPERATOR_PACKAGE');
  const [pkgPrice, setPkgPrice] = useState('72000');
  const [pkgDuration, setPkgDuration] = useState('3 Days / 2 Nights');

  const handleAction = (id: string, action: 'ACCEPT' | 'DECLINE') => {
    setRequests((prev) =>
      prev.map((r) => {
        if (r.id === id) {
          return {
            ...r,
            status: action === 'ACCEPT' ? 'ACCEPTED' : 'DECLINED',
          };
        }
        return r;
      })
    );

    const msg =
      action === 'ACCEPT'
        ? `Request #${id} accepted! Status transitioned to PROVIDER_ACCEPTED. Notification dispatched to traveller.`
        : `Request #${id} declined. TripGraph notified to trigger replacement workflow.`;
    setNotification(msg);
    setTimeout(() => setNotification(null), 5000);
  };

  const handleUploadDoc = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newDocNumber.trim()) return;

    const newDoc: ProviderDoc = {
      id: `doc-${Date.now().toString().slice(-4)}`,
      type: newDocType,
      number: newDocNumber,
      expiry: '31 Dec 2027',
      status: 'PENDING',
      notes: 'Submitted for Admin Review & SLTDA cross-check',
    };

    setDocs((prev) => [...prev, newDoc]);
    setNewDocNumber('');
    setShowDocModal(false);
    setNotification(`Document '${newDocType}' uploaded successfully and queued for Admin Verification.`);
    setTimeout(() => setNotification(null), 5000);
  };

  // Financial calculations
  const totalBookingsValue = requests
    .filter((r) => r.status === 'ACCEPTED')
    .reduce((acc, r) => acc + r.amountLKR, 0);
  const totalCommission = Math.round(totalBookingsValue * 0.10);
  const netPayable = totalBookingsValue - totalCommission;

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
          background: 'linear-gradient(135deg, rgba(16, 42, 67, 0.7) 0%, rgba(11, 110, 142, 0.15) 100%)',
          padding: '24px 28px',
          borderRadius: 'var(--radius-md)',
          border: '1px solid rgba(27, 166, 166, 0.25)',
          boxShadow: '0 8px 32px rgba(0, 0, 0, 0.25)',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '20px' }}>
          <img
            src="/traverza-logo.jpg"
            alt="TRAVERZA Provider OS"
            style={{
              width: '60px',
              height: '60px',
              borderRadius: '14px',
              objectFit: 'cover',
              boxShadow: '0 8px 24px rgba(11, 110, 142, 0.45)',
              border: '2px solid rgba(27, 166, 166, 0.4)',
            }}
          />
          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
              <h1 style={{ fontSize: '2.0rem', margin: 0 }}>TRAVERZA Provider OS</h1>
              <span className="badge badge-emerald">SLTDA Scope Approved</span>
            </div>
            <p style={{ color: 'var(--text-secondary)', marginTop: '6px', marginBottom: 0 }}>
              Organisation: <strong>Boutique Heritage Stays (Pvt) Ltd</strong> • Licence: <strong>SLTDA/SQ/2026/089</strong> • Corridor: <strong>Cultural Triangle</strong>
            </p>
          </div>
        </div>

        <div style={{ display: 'flex', gap: '12px' }}>
          <Link href="/" className="btn btn-secondary">
            View Traveller Canvas
          </Link>
          <button onClick={() => setShowPackageModal(true)} className="btn btn-secondary" style={{ borderColor: 'var(--secondary)' }}>
            + Create Package
          </button>
          <button onClick={() => setShowDocModal(true)} className="btn btn-primary">
            + Upload Credentials
          </button>
        </div>
      </div>

      {/* Tabs */}
      <div style={{ display: 'flex', gap: '12px', marginBottom: '24px', flexWrap: 'wrap' }}>
        <button
          onClick={() => setActiveTab('inbox')}
          className={`btn ${activeTab === 'inbox' ? 'btn-primary' : 'btn-secondary'}`}
        >
          Request Inbox ({requests.filter((r) => r.status === 'PENDING').length})
        </button>
        <button
          onClick={() => setActiveTab('packages')}
          className={`btn ${activeTab === 'packages' ? 'btn-primary' : 'btn-secondary'}`}
        >
          Packages & Routes ({packages.length})
        </button>
        <button
          onClick={() => setActiveTab('compliance')}
          className={`btn ${activeTab === 'compliance' ? 'btn-primary' : 'btn-secondary'}`}
        >
          Compliance & Documents ({docs.length})
        </button>
        <button
          onClick={() => setActiveTab('finance')}
          className={`btn ${activeTab === 'finance' ? 'btn-primary' : 'btn-secondary'}`}
        >
          Financial Statement & Ledger
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

      {/* Tab 1: Request-to-Confirm Inbox */}
      {activeTab === 'inbox' && (
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 340px', gap: '32px' }}>
          <div>
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
                  <h2 style={{ fontSize: '1.3rem' }}>Request-to-Confirm Inbox</h2>
                  <p style={{ fontSize: '0.82rem', color: 'var(--text-muted)' }}>
                    Gate 3 Rule: Providers have 12 hours to accept or decline before quote auto-expires.
                  </p>
                </div>
                <span className="badge badge-amber">
                  {requests.filter((r) => r.status === 'PENDING').length} Pending Requests
                </span>
              </div>

              <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                {requests.map((req) => (
                  <div
                    key={req.id}
                    style={{
                      background: 'rgba(255, 255, 255, 0.02)',
                      border: '1px solid var(--border-glass)',
                      borderRadius: 'var(--radius-sm)',
                      padding: '20px',
                    }}
                  >
                    <div
                      style={{
                        display: 'flex',
                        justifyContent: 'space-between',
                        alignItems: 'flex-start',
                        marginBottom: '12px',
                      }}
                    >
                      <div>
                        <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>
                          Request #{req.id} • {req.tripId}
                        </div>
                        <h3 style={{ fontSize: '1.15rem', marginTop: '2px' }}>{req.service}</h3>
                        <div style={{ fontSize: '0.88rem', color: 'var(--text-secondary)' }}>
                          Traveler: <strong>{req.traveler}</strong> ({req.guests} Guests)
                        </div>
                      </div>

                      <div style={{ textAlign: 'right' }}>
                        <div
                          style={{
                            fontFamily: 'var(--font-heading)',
                            fontWeight: 700,
                            fontSize: '1.15rem',
                            color: 'var(--accent-emerald)',
                          }}
                        >
                          LKR {req.amountLKR.toLocaleString()}
                        </div>
                        <div style={{ fontSize: '0.78rem', color: 'var(--accent-amber)', marginTop: '4px' }}>
                          ⏳ Expires in {Math.floor(req.expiresInMinutes / 60)}h {req.expiresInMinutes % 60}m
                        </div>
                      </div>
                    </div>

                    <div
                      style={{
                        display: 'flex',
                        justifyContent: 'space-between',
                        alignItems: 'center',
                        paddingTop: '14px',
                        borderTop: '1px solid var(--border-glass)',
                      }}
                    >
                      <div style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>
                        Date: <strong>{req.date}</strong> • Slot: <strong>{req.timeSlot}</strong>
                      </div>

                      <div>
                        {req.status === 'PENDING' ? (
                          <div style={{ display: 'flex', gap: '10px' }}>
                            <button
                              onClick={() => handleAction(req.id, 'DECLINE')}
                              className="btn btn-secondary"
                              style={{ fontSize: '0.82rem', padding: '6px 14px' }}
                            >
                              Decline
                            </button>
                            <button
                              onClick={() => handleAction(req.id, 'ACCEPT')}
                              className="btn btn-primary"
                              style={{ fontSize: '0.82rem', padding: '6px 18px' }}
                            >
                              Accept Request
                            </button>
                          </div>
                        ) : (
                          <span
                            className={`badge ${
                              req.status === 'ACCEPTED' ? 'badge-emerald' : 'badge-ruby'
                            }`}
                          >
                            {req.status === 'ACCEPTED' ? 'Accepted' : 'Declined'}
                          </span>
                        )}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Quick Metrics */}
          <div>
            <div className="glass-panel" style={{ padding: '24px' }}>
              <h3 style={{ fontSize: '1.15rem', marginBottom: '16px' }}>Service Performance</h3>
              <div style={{ display: 'flex', flexDirection: 'column', gap: '14px', fontSize: '0.88rem' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                  <span style={{ color: 'var(--text-secondary)' }}>Median Response:</span>
                  <strong>18 mins (Target &lt; 2h)</strong>
                </div>
                <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                  <span style={{ color: 'var(--text-secondary)' }}>Fulfilment Rate:</span>
                  <strong style={{ color: 'var(--accent-emerald)' }}>99.2%</strong>
                </div>
                <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                  <span style={{ color: 'var(--text-secondary)' }}>Verified Reviews:</span>
                  <strong>4.95 ★ (88 reviews)</strong>
                </div>
                <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                  <span style={{ color: 'var(--text-secondary)' }}>Tenant Scope:</span>
                  <span className="badge badge-sapphire" style={{ fontSize: '0.72rem' }}>
                    Org Boundary Enforced
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Tab 2: Compliance & Document Verification */}
      {activeTab === 'compliance' && (
        <div className="glass-panel" style={{ padding: '32px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
            <div>
              <h2 style={{ fontSize: '1.3rem' }}>SLTDA Compliance & Documents Vault</h2>
              <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)' }}>
                Audited evidence items required by Sri Lanka Tourism Development Authority (Section 14).
              </p>
            </div>
            <button onClick={() => setShowDocModal(true)} className="btn btn-primary" style={{ fontSize: '0.85rem' }}>
              + Upload Document
            </button>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
            {docs.map((doc) => (
              <div
                key={doc.id}
                style={{
                  padding: '18px',
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
                    <h4 style={{ fontSize: '1.05rem' }}>{doc.type}</h4>
                    <span
                      className={`badge ${
                        doc.status === 'APPROVED' ? 'badge-emerald' : 'badge-amber'
                      }`}
                      style={{ fontSize: '0.72rem' }}
                    >
                      {doc.status}
                    </span>
                  </div>
                  <div style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginTop: '4px' }}>
                    Reference Number: <strong style={{ fontFamily: 'monospace' }}>{doc.number}</strong> • Expiry: <strong>{doc.expiry}</strong>
                  </div>
                  <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)', marginTop: '2px' }}>
                    {doc.notes}
                  </div>
                </div>

                <button className="btn btn-secondary" style={{ fontSize: '0.8rem', padding: '6px 14px' }}>
                  Download Proof
                </button>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Tab 3: Financial Statement & Ledger */}
      {activeTab === 'finance' && (
        <div className="glass-panel" style={{ padding: '32px' }}>
          <h2 style={{ fontSize: '1.3rem', marginBottom: '8px' }}>Provider Settlement & Ledger Statement</h2>
          <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginBottom: '24px' }}>
            Section 12: Transparent commission ledger. Funds released to provider account following fulfilled tours.
          </p>

          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '20px', marginBottom: '32px' }}>
            <div style={{ padding: '20px', background: 'rgba(255, 255, 255, 0.03)', borderRadius: 'var(--radius-sm)' }}>
              <div style={{ color: 'var(--text-muted)', fontSize: '0.82rem' }}>Total Accepted Bookings</div>
              <div style={{ fontSize: '1.6rem', fontWeight: 800, marginTop: '6px', color: '#f8fafc' }}>
                LKR {totalBookingsValue.toLocaleString()}
              </div>
            </div>
            <div style={{ padding: '20px', background: 'rgba(255, 255, 255, 0.03)', borderRadius: 'var(--radius-sm)' }}>
              <div style={{ color: 'var(--text-muted)', fontSize: '0.82rem' }}>TRAVERZA Fee (10%)</div>
              <div style={{ fontSize: '1.6rem', fontWeight: 800, marginTop: '6px', color: 'var(--accent-amber)' }}>
                LKR {totalCommission.toLocaleString()}
              </div>
            </div>
            <div style={{ padding: '20px', background: 'rgba(255, 255, 255, 0.03)', borderRadius: 'var(--radius-sm)' }}>
              <div style={{ color: 'var(--text-muted)', fontSize: '0.82rem' }}>Net Provider Payout Balance</div>
              <div style={{ fontSize: '1.6rem', fontWeight: 800, marginTop: '6px', color: 'var(--accent-emerald)' }}>
                LKR {netPayable.toLocaleString()}
              </div>
            </div>
          </div>

          <div
            style={{
              padding: '16px',
              borderRadius: 'var(--radius-sm)',
              background: 'rgba(59, 130, 246, 0.08)',
              border: '1px solid rgba(59, 130, 246, 0.3)',
              fontSize: '0.85rem',
            }}
          >
            ℹ️ <strong>Settlement Cycle:</strong> Payouts are reconciled and transferred weekly to Commercial Bank of Ceylon A/C 1000-8409-2211 under SLTDA compliance rules.
          </div>
        </div>
      )}

      {/* TAB: PACKAGES & ROUTES */}
      {activeTab === 'packages' && (
        <div className="glass-panel" style={{ padding: '24px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
            <div>
              <h2 style={{ fontSize: '1.3rem', margin: 0 }}>Published Packages & Route Templates</h2>
              <p style={{ color: 'var(--text-secondary)', fontSize: '0.85rem', marginTop: '4px' }}>
                Curated offers submitted for SLTDA regulatory and TripGraph operational validation.
              </p>
            </div>
            <button onClick={() => setShowPackageModal(true)} className="btn btn-primary" style={{ fontSize: '0.85rem' }}>
              + Create New Journey
            </button>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            {packages.map((pkg) => (
              <div
                key={pkg.id}
                style={{
                  padding: '20px',
                  background: 'rgba(255, 255, 255, 0.02)',
                  borderRadius: 'var(--radius-sm)',
                  border: '1px solid var(--border-glass)',
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  flexWrap: 'wrap',
                  gap: '16px',
                }}
              >
                <div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                    <span
                      className={`badge ${
                        pkg.type === 'OPERATOR_PACKAGE' ? 'badge-primary' : 'badge-secondary'
                      }`}
                      style={{ fontSize: '0.72rem' }}
                    >
                      {pkg.type === 'OPERATOR_PACKAGE' ? 'OPERATOR BUNDLE' : 'ITINERARY TEMPLATE'}
                    </span>
                    <span
                      className={`badge ${
                        pkg.status === 'PUBLISHED'
                          ? 'badge-emerald'
                          : pkg.status === 'IN_REVIEW'
                          ? 'badge-amber'
                          : 'badge-secondary'
                      }`}
                    >
                      {pkg.status}
                    </span>
                    <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>v{pkg.version}.0</span>
                  </div>
                  <h3 style={{ fontSize: '1.15rem', marginTop: '8px', marginBottom: '4px' }}>{pkg.title}</h3>
                  <p style={{ color: 'var(--text-secondary)', fontSize: '0.82rem', margin: 0 }}>
                    Corridor: <strong>{pkg.corridor}</strong> • Duration: <strong>{pkg.duration}</strong> • SLTDA: <strong>{pkg.sltdaLicense}</strong>
                  </p>
                </div>

                <div style={{ display: 'flex', alignItems: 'center', gap: '20px' }}>
                  <div style={{ textAlign: 'right' }}>
                    <div style={{ fontSize: '1.25rem', fontWeight: 800, color: 'var(--accent-cyan)' }}>
                      LKR {pkg.priceLKR.toLocaleString()}
                    </div>
                    <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>{pkg.priceBasis}</div>
                  </div>
                  <button
                    onClick={() => {
                      setNotification(`Opened editor for ${pkg.title} (v${pkg.version}.0).`);
                      setTimeout(() => setNotification(null), 4000);
                    }}
                    className="btn btn-secondary"
                    style={{ fontSize: '0.8rem', padding: '8px 14px' }}
                  >
                    Edit Package
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Create Package Modal */}
      {showPackageModal && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            background: 'rgba(0, 0, 0, 0.75)',
            backdropFilter: 'blur(8px)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            zIndex: 1000,
          }}
        >
          <div
            className="glass-panel"
            style={{ width: '540px', padding: '32px', border: '1px solid var(--secondary)' }}
          >
            <h3 style={{ fontSize: '1.3rem', marginBottom: '16px' }}>Create Travel Package / Route</h3>
            <form
              onSubmit={(e) => {
                e.preventDefault();
                if (!pkgTitle.trim()) return;

                const newP: ProviderPackage = {
                  id: `pkg-${Date.now().toString().slice(-4)}`,
                  title: pkgTitle,
                  type: pkgType,
                  duration: pkgDuration,
                  priceBasis: pkgType === 'OPERATOR_PACKAGE' ? 'PER_PERSON (Bundled)' : 'ESTIMATED_PER_PERSON',
                  priceLKR: parseFloat(pkgPrice) || 68500,
                  status: 'IN_REVIEW',
                  corridor: 'Colombo · Sigiriya · Kandy · Nuwara Eliya',
                  version: 1,
                  sltdaLicense: 'SLTDA/SQA/2026/089',
                };

                setPackages((prev) => [newP, ...prev]);
                setShowPackageModal(false);
                setPkgTitle('');
                setNotification(`Package "${newP.title}" created & submitted for Admin Approval (Queue Ref: #REV-${Date.now().toString().slice(-4)}).`);
                setTimeout(() => setNotification(null), 5000);
              }}
            >
              <div style={{ marginBottom: '14px' }}>
                <label style={{ display: 'block', fontSize: '0.85rem', color: 'var(--text-secondary)', marginBottom: '6px' }}>
                  Package Classification (Spec §3)
                </label>
                <select
                  value={pkgType}
                  onChange={(e) => setPkgType(e.target.value as 'OPERATOR_PACKAGE' | 'ITINERARY_TEMPLATE')}
                  style={{
                    width: '100%',
                    padding: '10px',
                    borderRadius: 'var(--radius-sm)',
                    background: '#070b12',
                    border: '1px solid var(--border-glass)',
                    color: '#fff',
                  }}
                >
                  <option value="OPERATOR_PACKAGE">Type 1 — Operator Package (Bundled single seller offer)</option>
                  <option value="ITINERARY_TEMPLATE">Type 2 — Itinerary Template (Editorial route inspiration)</option>
                </select>
              </div>

              <div style={{ marginBottom: '14px' }}>
                <label style={{ display: 'block', fontSize: '0.85rem', color: 'var(--text-secondary)', marginBottom: '6px' }}>
                  Journey Title
                </label>
                <input
                  type="text"
                  placeholder="e.g. 3-Day Cultural Triangle Heritage & Safari Escape"
                  value={pkgTitle}
                  onChange={(e) => setPkgTitle(e.target.value)}
                  style={{
                    width: '100%',
                    padding: '10px',
                    borderRadius: 'var(--radius-sm)',
                    background: '#070b12',
                    border: '1px solid var(--border-glass)',
                    color: '#fff',
                  }}
                  required
                />
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '14px', marginBottom: '14px' }}>
                <div>
                  <label style={{ display: 'block', fontSize: '0.85rem', color: 'var(--text-secondary)', marginBottom: '6px' }}>
                    Duration
                  </label>
                  <input
                    type="text"
                    value={pkgDuration}
                    onChange={(e) => setPkgDuration(e.target.value)}
                    style={{
                      width: '100%',
                      padding: '10px',
                      borderRadius: 'var(--radius-sm)',
                      background: '#070b12',
                      border: '1px solid var(--border-glass)',
                      color: '#fff',
                    }}
                    required
                  />
                </div>
                <div>
                  <label style={{ display: 'block', fontSize: '0.85rem', color: 'var(--text-secondary)', marginBottom: '6px' }}>
                    Price Basis (LKR)
                  </label>
                  <input
                    type="number"
                    value={pkgPrice}
                    onChange={(e) => setPkgPrice(e.target.value)}
                    style={{
                      width: '100%',
                      padding: '10px',
                      borderRadius: 'var(--radius-sm)',
                      background: '#070b12',
                      border: '1px solid var(--border-glass)',
                      color: '#fff',
                    }}
                    required
                  />
                </div>
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px', marginTop: '20px' }}>
                <button
                  type="button"
                  onClick={() => setShowPackageModal(false)}
                  className="btn btn-secondary"
                  style={{ fontSize: '0.85rem' }}
                >
                  Cancel
                </button>
                <button type="submit" className="btn btn-primary" style={{ fontSize: '0.85rem' }}>
                  Submit for Admin Review
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Upload Document Modal */}
      {showDocModal && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            background: 'rgba(0, 0, 0, 0.75)',
            backdropFilter: 'blur(8px)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            zIndex: 1000,
          }}
        >
          <div
            className="glass-panel"
            style={{ width: '460px', padding: '32px', border: '1px solid var(--accent-emerald)' }}
          >
            <h3 style={{ fontSize: '1.3rem', marginBottom: '16px' }}>Upload Compliance Document</h3>
            <form onSubmit={handleUploadDoc}>
              <div style={{ marginBottom: '16px' }}>
                <label style={{ display: 'block', fontSize: '0.85rem', color: 'var(--text-secondary)', marginBottom: '6px' }}>
                  Document Type
                </label>
                <select
                  value={newDocType}
                  onChange={(e) => setNewDocType(e.target.value)}
                  style={{
                    width: '100%',
                    padding: '10px',
                    borderRadius: 'var(--radius-sm)',
                    background: '#070b12',
                    border: '1px solid var(--border-glass)',
                    color: '#fff',
                  }}
                >
                  <option value="Vehicle Fleet Commercial Permit">Vehicle Fleet Commercial Permit</option>
                  <option value="Chauffeur Guide SLTDA License">Chauffeur Guide SLTDA License</option>
                  <option value="Commercial Public Liability Cover">Commercial Public Liability Cover</option>
                  <option value="Fire & Safety Local Certificate">Fire & Safety Local Certificate</option>
                </select>
              </div>

              <div style={{ marginBottom: '20px' }}>
                <label style={{ display: 'block', fontSize: '0.85rem', color: 'var(--text-secondary)', marginBottom: '6px' }}>
                  Document / Certificate Number
                </label>
                <input
                  type="text"
                  placeholder="e.g. SLTDA/VP/2026/801"
                  value={newDocNumber}
                  onChange={(e) => setNewDocNumber(e.target.value)}
                  style={{
                    width: '100%',
                    padding: '10px',
                    borderRadius: 'var(--radius-sm)',
                    background: '#070b12',
                    border: '1px solid var(--border-glass)',
                    color: '#fff',
                  }}
                  required
                />
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px' }}>
                <button
                  type="button"
                  onClick={() => setShowDocModal(false)}
                  className="btn btn-secondary"
                  style={{ fontSize: '0.85rem' }}
                >
                  Cancel
                </button>
                <button type="submit" className="btn btn-primary" style={{ fontSize: '0.85rem' }}>
                  Submit for Verification
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
