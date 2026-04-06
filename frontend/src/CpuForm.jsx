import { useState } from 'react';

function CpuForm({ onCpuAdded, api }) {
    const [name,           setName]           = useState('');
    const [manufacturer,   setManufacturer]   = useState('');
    const [price,          setPrice]          = useState('');
    const [cores,          setCores]          = useState(8);
    const [warrantyMonths, setWarrantyMonths] = useState(36);

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            const res = await api.post('/cpus', {
                name,
                manufacturer,
                price:          parseFloat(price),
                cores:          parseInt(cores),
                warrantyMonths: parseInt(warrantyMonths),
            });
            alert('CPU saved!');
            onCpuAdded(res.data);
            setName(''); setManufacturer(''); setPrice(''); setCores(8); setWarrantyMonths(36);
        } catch (err) {
            console.error(err);
            alert('Failed to save CPU.');
        }
    };

    return (
        <form onSubmit={handleSubmit} className="form-style">
            <h3>🖥️ Add New CPU</h3>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                <input type="text"   placeholder="Name (e.g. Core i9-14900K)"  value={name}           onChange={e => setName(e.target.value)}           required />
                <input type="text"   placeholder="Manufacturer (e.g. Intel)"   value={manufacturer}   onChange={e => setManufacturer(e.target.value)}   required />
                <input type="number" placeholder="Price"             step="0.01" value={price}          onChange={e => setPrice(e.target.value)}          required />
                <input type="number" placeholder="Cores"                        value={cores}          onChange={e => setCores(e.target.value)}          required />
                <input type="number" placeholder="Warranty (months)"            value={warrantyMonths} onChange={e => setWarrantyMonths(e.target.value)} required />
                <button type="submit">Save CPU to Database</button>
            </div>
        </form>
    );
}

export default CpuForm;