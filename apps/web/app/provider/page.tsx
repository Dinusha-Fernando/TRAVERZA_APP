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
];

export default function ProviderPortalPage() {
  const [requests, setRequests] = useState<BookingRequest[]>(INITIAL_REQUESTS);
  const [notification, setNotification] = useState<string | null>(null);

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
        ? `Request ${id} accepted! Status transitioned to PROVIDER_ACCEPTED. Notification dispatched to traveler.`
        : `Request ${id} declined. TripGraph notified to trigger replacement workflow.`;
    setNotification(msg);
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
          gap: '16px',
        }}
      >
        <div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <h1 style={{ fontSize: '2.2rem' }}>Provider OS Dashboard</h1>
            <span className="badge badge-emerald">SLTDA Scope Approved</span>
          </div>
          <p style={{ color: 'var(--text-secondary)', marginTop: '4px' }}>
            Organisation: <strong>Boutique Heritage Stays (Pvt) Ltd</strong> • Licence: <strong>SLTDA/SQ/2026/089</strong>
          </p>
        </div>

        <div style={{ display: 'flex', gap: '12px' }}>
          <Link href="/" className="btn btn-secondary">
            View Live Itinerary
          </Link>
          <button className="btn btn-primary">+ New Service Listing</button>
        </div>
      </div>

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

      {/* Grid: Request Inbox & Compliance status */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 340px', gap: '32px' }}>
        {/* Request Inbox */}
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
              <h2 style={{ fontSize: '1.3rem' }}>Request-to-Confirm Inbox</h2>
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

        {/* Provider Compliance & Verification Sidebar */}
        <div>
          <div className="glass-panel" style={{ padding: '24px' }}>
            <h3 style={{ fontSize: '1.15rem', marginBottom: '16px' }}>Compliance & Credential Status</h3>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '14px', fontSize: '0.85rem' }}>
              <div
                style={{
                  padding: '12px',
                  borderRadius: 'var(--radius-sm)',
                  background: 'rgba(255, 255, 255, 0.02)',
                  border: '1px solid var(--border-glass)',
                }}
              >
                <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                  <span style={{ fontWeight: 600 }}>SLTDA Licence:</span>
                  <span style={{ color: '#34d399' }}>Verified</span>
                </div>
                <div style={{ color: 'var(--text-muted)', fontSize: '0.78rem', marginTop: '4px' }}>
                  Expires: 31 Dec 2026 • Scope: Stays
                </div>
              </div>

              <div
                style={{
                  padding: '12px',
                  borderRadius: 'var(--radius-sm)',
                  background: 'rgba(255, 255, 255, 0.02)',
                  border: '1px solid var(--border-glass)',
                }}
              >
                <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                  <span style={{ fontWeight: 600 }}>Public Liability:</span>
                  <span style={{ color: '#34d399' }}>Valid</span>
                </div>
                <div style={{ color: 'var(--text-muted)', fontSize: '0.78rem', marginTop: '4px' }}>
                  Cover: LKR 5,000,000 (SLTDA Mandate)
                </div>
              </div>

              <div
                style={{
                  padding: '12px',
                  borderRadius: 'var(--radius-sm)',
                  background: 'rgba(255, 255, 255, 0.02)',
                  border: '1px solid var(--border-glass)',
                }}
              >
                <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                  <span style={{ fontWeight: 600 }}>Tenant Boundary:</span>
                  <span style={{ color: '#60a5fa' }}>Org-Isolated</span>
                </div>
                <div style={{ color: 'var(--text-muted)', fontSize: '0.78rem', marginTop: '4px' }}>
                  Protected by X-Organization-ID RBAC
                </div>
              </div>
            </div>

            <div style={{ marginTop: '20px' }}>
              <button className="btn btn-secondary" style={{ width: '100%', fontSize: '0.85rem' }}>
                Upload Renewal Documents
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
