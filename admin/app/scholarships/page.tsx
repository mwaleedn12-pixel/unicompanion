'use client';
import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';

export default function ScholarshipsPage() {
  const [list, setList] = useState<any[]>([]);
  const [editing, setEditing] = useState<string|null>(null);
  const [form, setForm] = useState({ name:'', type:'merit', coverage:'', eligibility:'', deadline:'', apply_url:'' });

  useEffect(() => { load(); }, []);
  async function load() { const { data } = await supabase.from('scholarships').select().order('name'); setList(data || []); }
  async function save() {
    if (editing) { await supabase.from('scholarships').update(form).eq('id', editing); }
    else { await supabase.from('scholarships').insert(form); }
    setEditing(null); setForm({ name:'', type:'merit', coverage:'', eligibility:'', deadline:'', apply_url:'' }); load();
  }
  async function remove(id:string) { if (!confirm('Delete?')) return; await supabase.from('scholarships').delete().eq('id', id); load(); }

  return (
    <div>
      <h2 className="text-2xl font-bold mb-6">Scholarships ({list.length})</h2>
      <div className="bg-white rounded-xl p-6 shadow-sm border mb-6">
        <h3 className="font-semibold mb-4">{editing ? 'Edit' : 'Add'} Scholarship</h3>
        <div className="grid grid-cols-2 gap-3">
          <input className="border rounded-lg px-3 py-2 text-sm" placeholder="Name" value={form.name} onChange={e => setForm({...form, name: e.target.value})} />
          <select className="border rounded-lg px-3 py-2 text-sm" value={form.type} onChange={e => setForm({...form, type: e.target.value})}>
            <option value="merit">Merit</option><option value="need">Need-Based</option><option value="special">Special</option>
          </select>
          <input className="border rounded-lg px-3 py-2 text-sm" placeholder="Coverage" value={form.coverage} onChange={e => setForm({...form, coverage: e.target.value})} />
          <input className="border rounded-lg px-3 py-2 text-sm" placeholder="Deadline (YYYY-MM-DD)" value={form.deadline} onChange={e => setForm({...form, deadline: e.target.value})} />
          <input className="border rounded-lg px-3 py-2 text-sm" placeholder="Eligibility" value={form.eligibility} onChange={e => setForm({...form, eligibility: e.target.value})} />
          <input className="border rounded-lg px-3 py-2 text-sm" placeholder="Apply URL" value={form.apply_url} onChange={e => setForm({...form, apply_url: e.target.value})} />
        </div>
        <div className="mt-3 flex gap-2">
          <button onClick={save} className="bg-indigo-600 text-white px-4 py-2 rounded-lg text-sm">{editing ? 'Update' : 'Add'}</button>
          {editing && <button onClick={() => { setEditing(null); setForm({ name:'', type:'merit', coverage:'', eligibility:'', deadline:'', apply_url:'' }); }} className="border px-4 py-2 rounded-lg text-sm">Cancel</button>}
        </div>
      </div>
      <div className="bg-white rounded-xl shadow-sm border overflow-hidden">
        <table className="w-full text-sm"><thead className="bg-gray-50"><tr><th className="px-4 py-3 text-left">Name</th><th className="px-4 py-3 text-left">Type</th><th className="px-4 py-3 text-left">Coverage</th><th className="px-4 py-3 text-right">Actions</th></tr></thead>
          <tbody className="divide-y">{list.map((s:any) => (
            <tr key={s.id} className="hover:bg-gray-50">
              <td className="px-4 py-3 font-medium">{s.name}</td><td className="px-4 py-3">{s.type}</td><td className="px-4 py-3">{s.coverage}</td>
              <td className="px-4 py-3 text-right"><button onClick={() => { setEditing(s.id); setForm(s); }} className="text-indigo-600 hover:underline mr-3">Edit</button><button onClick={() => remove(s.id)} className="text-red-600 hover:underline">Delete</button></td>
            </tr>))}</tbody>
        </table>
      </div>
    </div>
  );
}