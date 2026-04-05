import { useState } from 'react';

function CpuForm({ onCpuAdded, api }) {
    const [warrantyMonths, setWarrantyMonths] = useState(36);
    const [cores,          setCores]          = useState(8);

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            const res = await api.post('/cpus', {
                warrantyMonths: parseInt(warrantyMonths),
                cores:          parseInt(cores),
            });
            alert('CPU saved!');
            onCpuAdded(res.data);
            setWarrantyMonths(36);
            setCores(8);
        } catch (err) {
            console.error(err);
            alert('Failed to save CPU.');
        }
    };

    return (
        <form onSubmit={handleSubmit} className="form-style"
              style={{ border: '2px solid #0d6efd', padding: '20px' }}>
            <h3>🖥️ Add New CPU</h3>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                <input type="number" placeholder="Cores"             value={cores}          onChange={e => setCores(e.target.value)}          required />
                <input type="number" placeholder="Warranty (months)" value={warrantyMonths} onChange={e => setWarrantyMonths(e.target.value)} required />
                <button type="submit" style={{ backgroundColor: '#0d6efd', color: 'white', padding: '10px' }}>
                    Save CPU to Database
                </button>
            </div>
        </form>
    );
}

export default CpuForm;