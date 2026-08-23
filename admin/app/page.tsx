'use client';

import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';

interface Stat {
  label: string;
  count: number;
  color: string;
}

export default function Dashboard() {
  const [stats, setStats] = useState<Stat[]>([]);

  useEffect(function () {
    async function load() {
      var tables = [
        { table: 'universities', label: 'Universities', color: 'bg-blue-500' },
        { table: 'scholarships', label: 'Scholarships', color: 'bg-yellow-500' },
        { table: 'jobs', label: 'Jobs', color: 'bg-purple-500' },
        { table: 'test_questions', label: 'Questions', color: 'bg-red-500' },
      ];

      var results: Stat[] = [];
      for (var i = 0; i < tables.length; i++) {
        var t = tables[i];
        var res = await supabase.from(t.table).select('*', { count: 'exact', head: true });
        results.push({ label: t.label, count: res.count || 0, color: t.color });
      }
      setStats(results);
    }
    load();
  }, []);

  if (stats.length === 0) {
    return <div style={{ padding: 40 }}><h2>Loading dashboard...</h2></div>;
  }

  return (
    <div>
      <h2 style={{ fontSize: 24, fontWeight: 'bold', marginBottom: 24 }}>Dashboard</h2>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 16 }}>
        {stats.map(function (s) {
          return (
            <div key={s.label} style={{ background: 'white', borderRadius: 12, padding: 24, border: '1px solid #e5e7eb' }}>
              <div style={{ fontSize: 32, fontWeight: 'bold' }}>{s.count}</div>
              <div style={{ fontSize: 14, color: '#6b7280', marginTop: 4 }}>{s.label}</div>
            </div>
          );
        })}
      </div>
    </div>
  );
}