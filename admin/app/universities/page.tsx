'use client';
import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';

type Uni = { id:string; name:string; type:string; ranking_national:number|null; description:string; website:string };

export default function UniversitiesPage() {
  const [list, setList] = useState<Uni[]>([]);
  const [editing, setEditing] = useState<string|null>(null);
  const [form, setForm] = useState({ name:'', type:'public', ranking_national:'', description:'', website:'' });

  useEffect(() => { load(); }, []);

  async function load() {
    const { data } = await supabase.from('universities').select().order('ranking_national');
    setList((data as Uni[]) || []);
  }

  async function save() {
    const payload = { ...form, ranking_national: form.ranking_national ? parseInt(form.ranking_national) : null };
    if (editing) {
      await supabase.from('universities').update(payload).eq('id', editing);
    } else {
      await supabase.from('universities').insert(payload);
    }
    setEditing(null);
    setForm({ name:'', type:'public', ranking_national:'', description:'', website:'' });
    load();
  }

  async function remove(id: string) {
    if (!confirm('Delete?')) return;
    await supabase.from('universities').delete().eq('id', id);
    load();
  }

  function edit(u: Uni) {
    setEditing(u.id);
    setForm({ name: u.name, type: u.type, ranking_national: u.ranking_national?.toString() || '', description: u.description || '', website: u.website || '' });
  }

  return (
    <div>
      <h2 className="text-2xl font-bold mb-6">Universities ({list.length})</h2>
      <div className="bg-white rounded-xl p-6 shadow-sm border mb-6">
        <h3 className="font-semibold mb-4">{editing ? 'Edit' : 'Add'} University</h3>
        <div className="grid grid-cols-2 gap-3">
          <input className="border rounded-lg px-3 py-2 text-sm" placeholder="Name" value={form.name} onChange={e => setForm({...form, name: e.target.value})} />
          <select className="border rounded-lg px-3 py-2 text-sm" value={form.type} onChange={e => setForm({...form, type: e.target.value})}>
            <option value="public">Public</option>
            <option value="private">Private</option>
          </select>
          <input className="border rounded-lg px-3 py-2 text-sm" placeholder="Ranking" type="number" value={form.ranking_national} onChange={e => setForm({...form, ranking_national: e.target.value})} />
          <input className="border rounded-lg px-3 py-2 text-sm" placeholder="Website" value={form.website} onChange={e => setForm({...form, website: e.target.value})} />
          <textarea className="border rounded-lg px-3 py-2 text-sm col-span-2" placeholder="Description" rows={2} value={form.description} onChange={e => setForm({...form, description: e.target.value})} />
        </div>
        <div className="mt-3 flex gap-2">
          <button onClick={save} className="bg-indigo-600 text-white px-4 py-2 rounded-lg text-sm hover:bg-indigo-700">{editing ? 'Update' : 'Add'}</button>
          {editing && <button onClick={() => { setEditing(null); setForm({ name:'', type:'public', ranking_national:'', description:'', website:'' }); }} className="border px-4 py-2 rounded-lg text-sm">Cancel</button>}
        </div>
      </div>
      <div className="bg-white rounded-xl shadow-sm border overflow-hidden">
        <table className="w-full text-sm">
          <thead className="bg-gray-50"><tr><th className="px-4 py-3 text-left">Name</th><th className="px-4 py-3 text-left">Type</th><th className="px-4 py-3 text-left">Rank</th><th className="px-4 py-3 text-right">Actions</th></tr></thead>
          <tbody className="divide-y">
            {list.map(u => (
              <tr key={u.id} className="hover:bg-gray-50">
                <td className="px-4 py-3 font-medium">{u.name}</td>
                <td className="px-4 py-3"><span className={`px-2 py-1 rounded text-xs font-medium ${u.type==='public'?'bg-blue-100 text-blue-700':'bg-purple-100 text-purple-700'}`}>{u.type}</span></td>
                <td className="px-4 py-3">{u.ranking_national ? `#${u.ranking_national}` : '--'}</td>
                <td className="px-4 py-3 text-right"><button onClick={() => edit(u)} className="text-indigo-600 hover:underline mr-3">Edit</button><button onClick={() => remove(u.id)} className="text-red-600 hover:underline">Delete</button></td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}