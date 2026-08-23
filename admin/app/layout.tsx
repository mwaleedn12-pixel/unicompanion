import './globals.css';
import Link from 'next/link';

const nav = [
  { href: '/', label: 'Dashboard', icon: '📊' },
  { href: '/universities', label: 'Universities', icon: '🏫' },
  { href: '/scholarships', label: 'Scholarships', icon: '💰' },
  { href: '/jobs', label: 'Jobs', icon: '💼' },
  { href: '/questions', label: 'Test Questions', icon: '📝' },
];

export const metadata = { title: 'UniCompanion Admin' };

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="bg-gray-50 min-h-screen flex">
        <aside className="w-60 bg-white border-r px-4 py-6 fixed h-full shadow-sm">
          <h1 className="text-lg font-bold text-indigo-600 mb-8 px-2">🎓 UniCompanion Admin</h1>
          <nav className="space-y-1">
            {nav.map(n => (
              <Link key={n.href} href={n.href}
                className="flex items-center gap-3 px-3 py-2.5 rounded-lg hover:bg-indigo-50 text-gray-600 hover:text-indigo-600 text-sm font-medium transition">
                <span>{n.icon}</span> {n.label}
              </Link>
            ))}
          </nav>
        </aside>
        <main className="ml-60 flex-1 p-8">{children}</main>
      </body>
    </html>
  );
}