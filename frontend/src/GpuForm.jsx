import { useState } from 'react';

function GpuForm({ onGpuAdded, api }) {
    const [warrantyMonths, setWarrantyMonths] = useState(36);
    const [vramGB,         setVramGB]         = useState(8);

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            const res = await api.post('/gpus', {
                warrantyMonths: parseInt(warrantyMonths),
                vramGB:         parseInt(vramGB),
            });
            alert('GPU saved!');
            onGpuAdded(res.data);
            setWarrantyMonths(36);
            setVramGB(8);
        } catch (err) {
            console.error(err);
            alert('Failed to save GPU.');
        }
    };

    return (
        <form onSubmit={handleSubmit} className="form-style"
              style={{ border: '2px solid #6f42c1', padding: '20px' }}>
            <h3>🎮 Add New GPU</h3>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                <input type="number" placeholder="VRAM (GB)"         value={vramGB}         onChange={e => setVramGB(e.target.value)}         required />
                <input type="number" placeholder="Warranty (months)" value={warrantyMonths} onChange={e => setWarrantyMonths(e.target.value)} required />
                <button type="submit" style={{ backgroundColor: '#6f42c1', color: 'white', padding: '10px' }}>
                    Save GPU to Database
                </button>
            </div>
        </form>
    );
}

export default GpuForm;