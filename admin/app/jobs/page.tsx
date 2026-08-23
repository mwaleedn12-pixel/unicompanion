'use client';
import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';

export default function JobsPage() {
  const [list, setList] = useState<any[]>([]);
  const [editing, setEditing] = useState<string|null>(null);
  const [form, setForm] = useState({ title:'', company:'', location:'', job_type:'internship', field:'', description:'', requirements:'', apply_url:'', salary_range:'', deadline:'' });

  useEffect(() => { load(); }, []);
  async function load() { const { data } = await supabase.from('jobs').select().order('created_at', { ascending: false }); setList(data || []); }
  async function save() {
    const payload = { ...form, deadline: form.deadline || null };
    if (editing) { await supabase.from('jobs').update(payload).eq('id', editing); }
    else { await supabase.from('jobs').insert(payload); }
    setEditing(null); setForm({ title:'', company:'', location:'', job_type:'internship', field:'', description:'', requirements:'', apply_url:'', salary_range:'', deadline:'' }); load();
  }
  async function remove(id:string) { if (!confirm('Delete?')) return; await supabase.from('jobs').delete().eq('id', id); load(); }

  return (
    <div>
      <h2 className="text-2xl font-bold mb-6">Jobs ({list.length})</h2>
      <div className="bg-white rounded-xl p-6 shadow-sm border mb-6">
        <h3 className="font-semibold mb-4">{editing ? 'Edit' : 'Add'} Job</h3>
        <div className="grid grid-cols-3 gap-3">
          <input className="border rounded-lg px-3 py-2 text-sm" placeholder="Title" value={form.title} onChange={e => setForm({...form, title: e.target.value})} />
          <input className="border rounded-lg px-3 py-2 text-sm" placeholder="Company" value={form.company} onChange={e => setForm({...form, company: e.target.value})} />
          <input className="border rounded-lg px-3 py-2 text-sm" placeholder="Location" value={form.location} onChange={e => setForm({...form, location: e.target.value})} />
          <select className="border rounded-lg px-3 py-2 text-sm" value={form.job_type} onChange={e => setForm({...form, job_type: e.target.value})}>
            <option value="internship">Internship</option><option value="full_time">Full-Time</option><option value="part_time">Part-Time</option><option value="remote">Remote</option>
          </select>
          <input className="border rounded-lg px-3 py-2 text-sm" placeholder="Field" value={form.field} onChange={e => setForm({...form, field: e.target.value})} />
          <input className="border rounded-lg px-3 py-2 text-sm" placeholder="Salary" value={form.salary_range} onChange={e => setForm({...form, salary_range: e.target.value})} />
          <input className="border rounded-lg px-3 py-2 text-sm" placeholder="Apply URL" value={form.apply_url} onChange={e => setForm({...form, apply_url: e.target.value})} />
          <input className="border rounded-lg px-3 py-2 text-sm" placeholder="Deadline" value={form.deadline} onChange={e => setForm({...form, deadline: e.target.value})} />
          <textarea className="border rounded-lg px-3 py-2 text-sm col-span-3" placeholder="Description" rows={2} value={form.description} onChange={e => setForm({...form, description: e.target.value})} />
        </div>
        <div className="mt-3"><button onClick={save} className="bg-indigo-600 text-white px-4 py-2 rounded-lg text-sm">{editing ? 'Update' : 'Add'}</button></div>
      </div>
      <div className="bg-white rounded-xl shadow-sm border overflow-hidden">
        <table className="w-full text-sm"><thead className="bg-gray-50"><tr><th className="px-4 py-3 text-left">Title</th><th className="px-4 py-3 text-left">Company</th><th className="px-4 py-3 text-left">Type</th><th className="px-4 py-3 text-right">Actions</th></tr></thead>
          <tbody className="divide-y">{list.map((j:any) => (
            <tr key={j.id} className="hover:bg-gray-50">
              <td className="px-4 py-3 font-medium">{j.title}</td><td className="px-4 py-3">{j.company}</td><td className="px-4 py-3">{j.job_type}</td>
              <td className="px-4 py-3 text-right"><button onClick={() => { setEditing(j.id); setForm(j); }} className="text-indigo-600 hover:underline mr-3">Edit</button><button onClick={() => remove(j.id)} className="text-red-600 hover:underline">Delete</button></td>
            </tr>))}</tbody>
        </table>
      </div>
    </div>
  );
}