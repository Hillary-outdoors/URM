/** The URMA mark: a two-peak range. Used in the app bars and on the login page. */
export function Mark({ size = 28 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 64 64" aria-hidden="true" style={{ display: 'block', flex: 'none' }}>
      <rect width="64" height="64" rx="14" fill="#1d3557" />
      <path d="M8 48 L24 20 L36 41 L43 29 L56 48 Z" fill="#ffffff" />
      <path d="M43 29 L56 48 H36 Z" fill="#d9541e" />
    </svg>
  );
}

/** The mark with the name beside it. */
export function Logo({ size = 28, sub }: { size?: number; sub?: string }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
      <Mark size={size} />
      <div>
        <div style={{ fontFamily: 'var(--display)', fontWeight: 700, fontSize: size * 0.68, letterSpacing: '0.04em', lineHeight: 1.1 }}>URMA</div>
        {sub && <div style={{ fontSize: 12, opacity: 0.8, lineHeight: 1.2 }}>{sub}</div>}
      </div>
    </div>
  );
}
