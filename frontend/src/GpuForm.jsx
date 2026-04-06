import { useState } from 'react';

function GpuForm({ onGpuAdded, api }) {
    const [name,           setName]           = useState('');
    const [manufacturer,   setManufacturer]   = useState('');
    const [price,          setPrice]          = useState('');
    const [vramGB,         setVramGB]         = useState(8);
    const [warrantyMonths, setWarrantyMonths] = useState(36);

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            const res = await api.post('/gpus', {
                name,
                manufacturer,
                price:          parseFloat(price),
                vramGB:         parseInt(vramGB),
                warrantyMonths: parseInt(warrantyMonths),
            });
            alert('GPU saved!');
            onGpuAdded(res.data);
            setName(''); setManufacturer(''); setPrice(''); setVramGB(8); setWarrantyMonths(36);
        } catch (err) {
            console.error(err);
            alert('Failed to save GPU.');
        }
    };

    return (
        <form onSubmit={handleSubmit} className="form-style">
            <h3>🎮 Add New GPU</h3>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                <input type="text"   placeholder="Name (e.g. RTX 4090)"        value={name}           onChange={e => setName(e.target.value)}           required />
                <input type="text"   placeholder="Manufacturer (e.g. NVIDIA)"  value={manufacturer}   onChange={e => setManufacturer(e.target.value)}   required />
                <input type="number" placeholder="Price"             step="0.01" value={price}          onChange={e => setPrice(e.target.value)}          required />
                <input type="number" placeholder="VRAM (GB)"                    value={vramGB}         onChange={e => setVramGB(e.target.value)}         required />
                <input type="number" placeholder="Warranty (months)"            value={warrantyMonths} onChange={e => setWarrantyMonths(e.target.value)} required />
                <button type="submit">Save GPU to Database</button>
            </div>
        </form>
    );
}

export default GpuForm;