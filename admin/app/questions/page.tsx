'use client';
import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';

export default function QuestionsPage() {
  const [list, setList] = useState<any[]>([]);
  const [editing, setEditing] = useState<string|null>(null);
  const [form, setForm] = useState({ test_type:'ecat', subject:'', question:'', option_a:'', option_b:'', option_c:'', option_d:'', correct_option:'a', explanation:'', difficulty:'medium' });

  useEffect(() => { load(); }, []);
  async function load() { const { data } = await supabase.from('test_questions').select().order('test_type'); setList(data || []); }
  async function save() {
    if (editing) { await supabase.from('test_questions').update(form).eq('id', editing); }
    else { await supabase.from('test_questions').insert(form); }
    setEditing(null); setForm({ test_type:'ecat', subject:'', question:'', option_a:'', option_b:'', option_c:'', option_d:'', correct_option:'a', explanation:'', difficulty:'medium' }); load();
  }
  async function remove(id:string) { if (!confirm('Delete?')) return; await supabase.from('test_questions').delete().eq('id', id); load(); }

  return (
    <div>
      <h2 className="text-2xl font-bold mb-6">Test Questions ({list.length})</h2>
      <div className="bg-white rounded-xl p-6 shadow-sm border mb-6">
        <h3 className="font-semibold mb-4">{editing ? 'Edit' : 'Add'} Question</h3>
        <div className="grid grid-cols-3 gap-3">
          <select className="border rounded-lg px-3 py-2 text-sm" value={form.test_type} onChange={e => setForm({...form, test_type: e.target.value})}>
            <option value="ecat">ECAT</option><option value="mdcat">MDCAT</option><option value="net">NET</option><option value="gat">GAT</option><option value="nts">NTS</option>
          </select>
          <input className="border rounded-lg px-3 py-2 text-sm" placeholder="Subject" value={form.subject} onChange={e => setForm({...form, subject: e.target.value})} />
          <select className="border rounded-lg px-3 py-2 text-sm" value={form.difficulty} onChange={e => setForm({...form, difficulty: e.target.value})}>
            <option value="easy">Easy</option><option value="medium">Medium</option><option value="hard">Hard</option>
          </select>
          <textarea className="border rounded-lg px-3 py-2 text-sm col-span-3" placeholder="Question" rows={2} value={form.question} onChange={e => setForm({...form, question: e.target.value})} />
          <input className="border rounded-lg px-3 py-2 text-sm" placeholder="Option A" value={form.option_a} onChange={e => setForm({...form, option_a: e.target.value})} />
          <input className="border rounded-lg px-3 py-2 text-sm" placeholder="Option B" value={form.option_b} onChange={e => setForm({...form, option_b: e.target.value})} />
          <input className="border rounded-lg px-3 py-2 text-sm" placeholder="Option C" value={form.option_c} onChange={e => setForm({...form, option_c: e.target.value})} />
          <input className="border rounded-lg px-3 py-2 text-sm" placeholder="Option D" value={form.option_d} onChange={e => setForm({...form, option_d: e.target.value})} />
          <select className="border rounded-lg px-3 py-2 text-sm" value={form.correct_option} onChange={e => setForm({...form, correct_option: e.target.value})}>
            <option value="a">A</option><option value="b">B</option><option value="c">C</option><option value="d">D</option>
          </select>
          <textarea className="border rounded-lg px-3 py-2 text-sm col-span-3" placeholder="Explanation" rows={2} value={form.explanation} onChange={e => setForm({...form, explanation: e.target.value})} />
        </div>
        <div className="mt-3"><button onClick={save} className="bg-indigo-600 text-white px-4 py-2 rounded-lg text-sm">{editing ? 'Update' : 'Add'}</button></div>
      </div>
      <div className="bg-white rounded-xl shadow-sm border overflow-hidden">
        <table className="w-full text-sm"><thead className="bg-gray-50"><tr><th className="px-4 py-3 text-left">Test</th><th className="px-4 py-3 text-left">Subject</th><th className="px-4 py-3 text-left">Question</th><th className="px-4 py-3 text-left">Ans</th><th className="px-4 py-3 text-right">Actions</th></tr></thead>
          <tbody className="divide-y">{list.map((q:any) => (
            <tr key={q.id} className="hover:bg-gray-50">
              <td className="px-4 py-3 uppercase text-xs font-bold">{q.test_type}</td><td className="px-4 py-3">{q.subject}</td><td className="px-4 py-3 max-w-xs truncate">{q.question}</td><td className="px-4 py-3 uppercase font-bold">{q.correct_option}</td>
              <td className="px-4 py-3 text-right"><button onClick={() => { setEditing(q.id); setForm(q); }} className="text-indigo-600 hover:underline mr-3">Edit</button><button onClick={() => remove(q.id)} className="text-red-600 hover:underline">Delete</button></td>
            </tr>))}</tbody>
        </table>
      </div>
    </div>
  );
}