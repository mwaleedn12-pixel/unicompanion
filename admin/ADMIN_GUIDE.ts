// ================================================================
// UniCompanion Admin Panel — Next.js App Router
// Place in: admin/app/
// ================================================================

// ── app/layout.tsx ──
// Root layout with sidebar navigation

/*
import './globals.css';
import Link from 'next/link';

const navItems = [
  { href: '/admin', label: '📊 Dashboard', icon: '📊' },
  { href: '/admin/universities', label: '🏫 Universities', icon: '🏫' },
  { href: '/admin/programs', label: '📚 Programs', icon: '📚' },
  { href: '/admin/scholarships', label: '💰 Scholarships', icon: '💰' },
  { href: '/admin/jobs', label: '💼 Jobs', icon: '💼' },
  { href: '/admin/test-questions', label: '📝 Test Questions', icon: '📝' },
  { href: '/admin/users', label: '👥 Users', icon: '👥' },
];

export default function AdminLayout({ children }) {
  return (
    <html lang="en">
      <body className="bg-gray-50 min-h-screen flex">
        <aside className="w-64 bg-white border-r px-4 py-6 fixed h-full">
          <h1 className="text-xl font-bold text-indigo-600 mb-8">🎓 UniCompanion Admin</h1>
          <nav className="space-y-1">
            {navItems.map(item => (
              <Link key={item.href} href={item.href}
                className="flex items-center gap-3 px-3 py-2.5 rounded-lg hover:bg-indigo-50 text-gray-700 hover:text-indigo-600 text-sm font-medium transition">
                <span>{item.icon}</span> {item.label}
              </Link>
            ))}
          </nav>
        </aside>
        <main className="ml-64 flex-1 p-8">{children}</main>
      </body>
    </html>
  );
}
*/

// ── app/admin/page.tsx — Dashboard ──

/*
import { supabase } from '@/lib/supabase';

export default async function DashboardPage() {
  const [
    { count: uniCount },
    { count: userCount },
    { count: jobCount },
    { count: scholarshipCount },
    { count: questionCount },
    { count: reviewCount },
    { count: discussionCount },
  ] = await Promise.all([
    supabase.from('universities').select('*', { count: 'exact', head: true }),
    supabase.from('user_profiles').select('*', { count: 'exact', head: true }),
    supabase.from('jobs').select('*', { count: 'exact', head: true }),
    supabase.from('scholarships').select('*', { count: 'exact', head: true }),
    supabase.from('test_questions').select('*', { count: 'exact', head: true }),
    supabase.from('university_reviews').select('*', { count: 'exact', head: true }),
    supabase.from('discussions').select('*', { count: 'exact', head: true }),
  ]);

  const stats = [
    { label: 'Universities', count: uniCount, color: 'bg-blue-500' },
    { label: 'Users', count: userCount, color: 'bg-green-500' },
    { label: 'Jobs', count: jobCount, color: 'bg-purple-500' },
    { label: 'Scholarships', count: scholarshipCount, color: 'bg-yellow-500' },
    { label: 'Test Questions', count: questionCount, color: 'bg-red-500' },
    { label: 'Reviews', count: reviewCount, color: 'bg-indigo-500' },
    { label: 'Discussions', count: discussionCount, color: 'bg-pink-500' },
  ];

  return (
    <div>
      <h2 className="text-2xl font-bold mb-6">Dashboard</h2>
      <div className="grid grid-cols-4 gap-4">
        {stats.map(s => (
          <div key={s.label} className="bg-white rounded-xl p-6 shadow-sm border">
            <div className={`w-10 h-10 ${s.color} rounded-lg flex items-center justify-center text-white text-lg mb-3`}>
              {s.count ?? 0}
            </div>
            <div className="text-2xl font-bold">{s.count ?? 0}</div>
            <div className="text-sm text-gray-500">{s.label}</div>
          </div>
        ))}
      </div>
    </div>
  );
}
*/

// ── app/admin/universities/page.tsx — Universities CRUD ──

/*
'use client';
import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';

export default function UniversitiesPage() {
  const [universities, setUniversities] = useState([]);
  const [editing, setEditing] = useState(null);
  const [form, setForm] = useState({ name: '', type: 'public', ranking_national: '', description: '', website: '' });

  useEffect(() => { load(); }, []);

  async function load() {
    const { data } = await supabase.from('universities').select().order('ranking_national');
    setUniversities(data || []);
  }

  async function save() {
    if (editing) {
      await supabase.from('universities').update(form).eq('id', editing);
    } else {
      await supabase.from('universities').insert(form);
    }
    setEditing(null);
    setForm({ name: '', type: 'public', ranking_national: '', description: '', website: '' });
    load();
  }

  async function remove(id) {
    if (!confirm('Delete this university?')) return;
    await supabase.from('universities').delete().eq('id', id);
    load();
  }

  return (
    <div>
      <h2 className="text-2xl font-bold mb-6">Universities</h2>

      {/* Form */}
      <div className="bg-white rounded-xl p-6 shadow-sm border mb-6">
        <h3 className="font-semibold mb-4">{editing ? 'Edit University' : 'Add University'}</h3>
        <div className="grid grid-cols-2 gap-4">
          <input className="border rounded-lg px-3 py-2" placeholder="Name" value={form.name} onChange={e => setForm({...form, name: e.target.value})} />
          <select className="border rounded-lg px-3 py-2" value={form.type} onChange={e => setForm({...form, type: e.target.value})}>
            <option value="public">Public</option>
            <option value="private">Private</option>
          </select>
          <input className="border rounded-lg px-3 py-2" placeholder="National Ranking" type="number" value={form.ranking_national} onChange={e => setForm({...form, ranking_national: e.target.value})} />
          <input className="border rounded-lg px-3 py-2" placeholder="Website URL" value={form.website} onChange={e => setForm({...form, website: e.target.value})} />
          <textarea className="border rounded-lg px-3 py-2 col-span-2" placeholder="Description" rows={3} value={form.description} onChange={e => setForm({...form, description: e.target.value})} />
        </div>
        <div className="mt-4 flex gap-2">
          <button onClick={save} className="bg-indigo-600 text-white px-4 py-2 rounded-lg hover:bg-indigo-700">{editing ? 'Update' : 'Add'}</button>
          {editing && <button onClick={() => { setEditing(null); setForm({ name: '', type: 'public', ranking_national: '', description: '', website: '' }); }} className="border px-4 py-2 rounded-lg">Cancel</button>}
        </div>
      </div>

      {/* Table */}
      <div className="bg-white rounded-xl shadow-sm border overflow-hidden">
        <table className="w-full text-sm">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-4 py-3 text-left font-medium">Name</th>
              <th className="px-4 py-3 text-left font-medium">Type</th>
              <th className="px-4 py-3 text-left font-medium">Rank</th>
              <th className="px-4 py-3 text-right font-medium">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y">
            {universities.map(u => (
              <tr key={u.id} className="hover:bg-gray-50">
                <td className="px-4 py-3 font-medium">{u.name}</td>
                <td className="px-4 py-3"><span className={`px-2 py-1 rounded text-xs font-medium ${u.type === 'public' ? 'bg-blue-100 text-blue-700' : 'bg-purple-100 text-purple-700'}`}>{u.type}</span></td>
                <td className="px-4 py-3">{u.ranking_national ? `#${u.ranking_national}` : '--'}</td>
                <td className="px-4 py-3 text-right">
                  <button onClick={() => { setEditing(u.id); setForm(u); }} className="text-indigo-600 hover:underline mr-3">Edit</button>
                  <button onClick={() => remove(u.id)} className="text-red-600 hover:underline">Delete</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
*/

// ══════════════════════════════════════════════════════
// SAME PATTERN for other pages:
// - /admin/programs → CRUD on `programs` table
// - /admin/scholarships → CRUD on `scholarships` table
// - /admin/jobs → CRUD on `jobs` table
// - /admin/test-questions → CRUD on `test_questions` table
// - /admin/users → Read-only view of `user_profiles` table
//
// Each page follows the exact same pattern as Universities above:
// useState for list + form, useEffect to load, save/remove functions,
// a form section + a table section.
//
// TO SET UP:
// 1. cd admin && npm install
// 2. Create admin/.env.local with SUPABASE_URL + SERVICE_ROLE_KEY
// 3. npm run dev → http://localhost:3000/admin
// ══════════════════════════════════════════════════════