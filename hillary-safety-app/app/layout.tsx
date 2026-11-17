import './globals.css';
import type { Metadata, Viewport } from 'next';

export const metadata: Metadata = {
  title: 'URMA · Hillary Outdoors',
  description: 'Universal Record Management App: intentions, competencies and AMPs for Hillary Outdoors staff.',
  applicationName: 'URMA',
  appleWebApp: { capable: true, title: 'URMA', statusBarStyle: 'default' },
  robots: { index: false, follow: false },
};
// viewportFit lets the page use the whole screen on a notched phone; the CSS then keeps
// the top bar and the bottom nav clear of the notch and the home bar.
export const viewport: Viewport = { width: 'device-width', initialScale: 1, themeColor: '#1d3557', viewportFit: 'cover' };

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link href="https://fonts.googleapis.com/css2?family=Archivo:wght@500;600;700&family=IBM+Plex+Sans:wght@400;500;600&family=IBM+Plex+Mono:wght@400;500&display=swap" rel="stylesheet" />
      </head>
      <body>{children}</body>
    </html>
  );
}
