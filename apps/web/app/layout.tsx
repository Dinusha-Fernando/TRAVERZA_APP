import type { Metadata } from 'next';
import './globals.css';
import Link from 'next/link';

export const metadata: Metadata = {
  title: 'TRAVERZA | Connected Travel Operating Platform for Sri Lanka',
  description:
    'Experience Sri Lanka with coordinated multi-stop journeys. Discover, validate, and book verified boutique stays, licensed chauffeur transfers, and certified cultural guides.',
  keywords: [
    'Sri Lanka Travel',
    'Curated Itinerary',
    'SLTDA Verified Providers',
    'Chauffeur Guide Sri Lanka',
    'Cultural Triangle',
    'Kandy',
    'Sigiriya',
    'TripGraph',
  ],
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>
        <header className="glass-nav">
          <div
            style={{
              maxWidth: '1280px',
              margin: '0 auto',
              padding: '16px 24px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: '32px' }}>
              <Link href="/" style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <div
                  style={{
                    width: '36px',
                    height: '36px',
                    borderRadius: '10px',
                    background: 'linear-gradient(135deg, #10b981 0%, #3b82f6 100%)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontWeight: 800,
                    fontSize: '1.2rem',
                    color: '#fff',
                    boxShadow: '0 4px 12px rgba(16, 185, 129, 0.4)',
                  }}
                >
                  T
                </div>
                <div style={{ display: 'flex', flexDirection: 'column' }}>
                  <span
                    style={{
                      fontFamily: 'var(--font-heading)',
                      fontWeight: 800,
                      fontSize: '1.3rem',
                      letterSpacing: '0.04em',
                      color: '#ffffff',
                    }}
                  >
                    TRAVERZA
                  </span>
                  <span
                    style={{
                      fontSize: '0.65rem',
                      color: 'var(--accent-emerald)',
                      letterSpacing: '0.12em',
                      fontWeight: 700,
                    }}
                  >
                    SRI LANKA
                  </span>
                </div>
              </Link>

              <nav style={{ display: 'flex', gap: '20px' }}>
                <Link
                  href="/"
                  style={{
                    color: 'var(--text-primary)',
                    fontWeight: 600,
                    fontSize: '0.92rem',
                    transition: 'color var(--transition-fast)',
                  }}
                >
                  Explore Corridor
                </Link>
                <Link
                  href="/provider"
                  style={{
                    color: 'var(--text-secondary)',
                    fontWeight: 500,
                    fontSize: '0.92rem',
                    transition: 'color var(--transition-fast)',
                  }}
                >
                  Provider OS
                </Link>
                <Link
                  href="/admin"
                  style={{
                    color: 'var(--text-secondary)',
                    fontWeight: 500,
                    fontSize: '0.92rem',
                    transition: 'color var(--transition-fast)',
                  }}
                >
                  Trip Ops
                </Link>
              </nav>
            </div>

            <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
              <span className="badge badge-emerald">Pilot: Cultural Triangle</span>
              <Link href="/provider" className="btn btn-secondary" style={{ fontSize: '0.85rem', padding: '8px 16px' }}>
                Provider Portal
              </Link>
              <Link href="/" className="btn btn-primary" style={{ fontSize: '0.85rem', padding: '8px 18px' }}>
                Plan My Journey
              </Link>
            </div>
          </div>
        </header>

        <main>{children}</main>

        <footer
          style={{
            borderTop: '1px solid var(--border-glass)',
            background: 'var(--bg-surface)',
            padding: '48px 24px',
            marginTop: '80px',
          }}
        >
          <div
            style={{
              maxWidth: '1280px',
              margin: '0 auto',
              display: 'flex',
              flexWrap: 'wrap',
              justifyContent: 'space-between',
              gap: '32px',
            }}
          >
            <div>
              <h3 style={{ fontSize: '1.2rem', marginBottom: '8px' }}>TRAVERZA</h3>
              <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', maxWidth: '340px' }}>
                Connected travel operating platform for Sri Lanka. Curating verified stays, licensed chauffeur guides, and authentic excursions.
              </p>
            </div>
            <div style={{ display: 'flex', gap: '48px' }}>
              <div>
                <h4 style={{ fontSize: '0.95rem', marginBottom: '12px', color: 'var(--accent-gold)' }}>Regulatory & Trust</h4>
                <ul style={{ listStyle: 'none', display: 'flex', flexDirection: 'column', gap: '8px', fontSize: '0.85rem', color: 'var(--text-muted)' }}>
                  <li>SLTDA App Registered Merchant Standard</li>
                  <li>PDPA (Sri Lanka 2027) Privacy Architecture</li>
                  <li>ISO/IEC 27001 Readiness</li>
                  <li>Truthful Partial Confirmation Guarantee</li>
                </ul>
              </div>
              <div>
                <h4 style={{ fontSize: '0.95rem', marginBottom: '12px', color: 'var(--accent-emerald)' }}>Corridor Focus</h4>
                <ul style={{ listStyle: 'none', display: 'flex', flexDirection: 'column', gap: '8px', fontSize: '0.85rem', color: 'var(--text-muted)' }}>
                  <li>Bandaranaike Intl Airport (CMB)</li>
                  <li>Sigiriya & Dambulla Heritage</li>
                  <li>Kandy Sacred City & Highlands</li>
                  <li>Nuwara Eliya Tea Estates</li>
                </ul>
              </div>
            </div>
          </div>
          <div
            style={{
              maxWidth: '1280px',
              margin: '32px auto 0',
              paddingTop: '20px',
              borderTop: '1px solid rgba(255, 255, 255, 0.05)',
              textAlign: 'center',
              fontSize: '0.8rem',
              color: 'var(--text-muted)',
            }}
          >
            &copy; 2026 TRAVERZA. Built with FastAPI + PostgreSQL/PostGIS + Next.js + Flutter. All rights reserved.
          </div>
        </footer>
      </body>
    </html>
  );
}
