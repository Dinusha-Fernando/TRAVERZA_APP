import type { Metadata } from 'next';
import './globals.css';
import Image from 'next/image';
import Link from 'next/link';

export const metadata: Metadata = {
  title: 'TRAVERZA Operations Console | Master Admin Desk',
  description:
    'Internal Master Operations Command Center for TRAVERZA Sri Lanka. Centralized management across 12 operational domains.',
  icons: {
    icon: '/traverza-logo.jpg',
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>
        {/* Executive Admin Operations Navigation Header */}
        <header
          style={{
            position: 'sticky',
            top: 0,
            zIndex: 100,
            background: 'rgba(7, 59, 92, 0.96)',
            backdropFilter: 'blur(16px)',
            WebkitBackdropFilter: 'blur(16px)',
            borderBottom: '1px solid rgba(34, 184, 207, 0.3)',
            boxShadow: '0 4px 20px rgba(7, 59, 92, 0.25)',
          }}
        >
          <div
            style={{
              maxWidth: '1440px',
              margin: '0 auto',
              padding: '12px 24px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              gap: '16px',
            }}
          >
            {/* Left: Brand & Admin Console Badge */}
            <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
              <Link href="/admin" style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                <Image
                  src="/traverza-logo.jpg"
                  alt="TRAVERZA"
                  width={38}
                  height={38}
                  style={{
                    borderRadius: '10px',
                    objectFit: 'cover',
                    boxShadow: '0 2px 10px rgba(0, 0, 0, 0.2)',
                    border: '1.5px solid rgba(255, 255, 255, 0.4)',
                  }}
                />
                <div style={{ display: 'flex', flexDirection: 'column' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <span
                      style={{
                        fontFamily: 'var(--font-heading)',
                        fontWeight: 800,
                        fontSize: '1.25rem',
                        letterSpacing: '0.04em',
                        color: '#ffffff',
                      }}
                    >
                      TRAVERZA
                    </span>
                    <span
                      style={{
                        background: 'rgba(34, 184, 207, 0.25)',
                        border: '1px solid #22b8cf',
                        color: '#22b8cf',
                        padding: '2px 8px',
                        borderRadius: '6px',
                        fontSize: '0.68rem',
                        fontWeight: 700,
                        letterSpacing: '0.06em',
                        textTransform: 'uppercase',
                      }}
                    >
                      Admin Console
                    </span>
                  </div>
                  <span
                    style={{
                      fontSize: '0.68rem',
                      color: 'rgba(255, 255, 255, 0.7)',
                      letterSpacing: '0.08em',
                      fontWeight: 500,
                    }}
                  >
                    MASTER OPERATIONS DESK • SRI LANKA
                  </span>
                </div>
              </Link>
            </div>

            {/* Right: Operational Status Badges & Admin User Badge */}
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px', flexWrap: 'wrap' }}>
              <div
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '6px',
                  background: 'rgba(52, 211, 153, 0.15)',
                  border: '1px solid rgba(52, 211, 153, 0.4)',
                  padding: '5px 12px',
                  borderRadius: '999px',
                  fontSize: '0.75rem',
                  fontWeight: 600,
                  color: '#34d399',
                }}
              >
                <span
                  style={{
                    width: '7px',
                    height: '7px',
                    borderRadius: '50%',
                    background: '#34d399',
                    boxShadow: '0 0 8px #34d399',
                  }}
                />
                System Operational
              </div>

              <div
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '6px',
                  background: 'rgba(255, 255, 255, 0.1)',
                  border: '1px solid rgba(255, 255, 255, 0.2)',
                  padding: '5px 12px',
                  borderRadius: '999px',
                  fontSize: '0.75rem',
                  fontWeight: 500,
                  color: '#ffffff',
                }}
              >
                <span>🛡️</span> PDPA / ISO 27001
              </div>

              <div
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '8px',
                  background: 'rgba(255, 255, 255, 0.12)',
                  border: '1px solid rgba(255, 255, 255, 0.25)',
                  padding: '4px 12px 4px 6px',
                  borderRadius: '999px',
                }}
              >
                <span
                  style={{
                    width: '24px',
                    height: '24px',
                    borderRadius: '50%',
                    background: 'var(--color-secondary)',
                    color: '#ffffff',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontSize: '0.75rem',
                    fontWeight: 700,
                  }}
                >
                  SA
                </span>
                <div style={{ display: 'flex', flexDirection: 'column' }}>
                  <span style={{ fontSize: '0.75rem', fontWeight: 700, color: '#ffffff', lineHeight: 1.2 }}>
                    Super Admin
                  </span>
                  <span style={{ fontSize: '0.65rem', color: 'rgba(255, 255, 255, 0.65)', lineHeight: 1 }}>
                    admin@traverza.lk
                  </span>
                </div>
              </div>
            </div>
          </div>
        </header>

        <main>{children}</main>

        <footer
          style={{
            borderTop: '1px solid var(--color-border)',
            background: 'var(--bg-surface)',
            padding: '24px',
            marginTop: '60px',
            textAlign: 'center',
            fontSize: '0.8rem',
            color: 'var(--text-muted)',
          }}
        >
          <div
            style={{
              maxWidth: '1440px',
              margin: '0 auto',
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center',
              flexWrap: 'wrap',
              gap: '16px',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <span style={{ fontWeight: 700, color: 'var(--color-primary)' }}>TRAVERZA</span>
              <span>• Internal Operations Desk (v1.0.0-PROD)</span>
            </div>
            <div>
              Restricted Access • Authorized Personnel Only • Governed by Sri Lanka Personal Data Protection Act (PDPA 2027)
            </div>
            <div>
              &copy; 2026 TRAVERZA Sri Lanka. All administrative rights reserved.
            </div>
          </div>
        </footer>
      </body>
    </html>
  );
}
