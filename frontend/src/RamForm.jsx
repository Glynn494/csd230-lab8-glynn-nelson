import { useState } from 'react';

function RamForm({ onRamAdded, api }) {
    const [name,           setName]           = useState('');
    const [manufacturer,   setManufacturer]   = useState('');
    const [price,          setPrice]          = useState('');
    const [capacityGB,     setCapacityGB]     = useState(16);
    const [generation,     setGeneration]     = useState('DDR5');
    const [speedMHz,       setSpeedMHz]       = useState(6000);
    const [warrantyMonths, setWarrantyMonths] = useState(36);

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            const res = await api.post('/ram', {
                name,
                manufacturer,
                price:          parseFloat(price),
                capacityGB:     parseInt(capacityGB),
                generation,
                speedMHz:       parseInt(speedMHz),
                warrantyMonths: parseInt(warrantyMonths),
            });
            alert('RAM saved!');
            onRamAdded(res.data);
            setName(''); setManufacturer(''); setPrice(''); setCapacityGB(16);
            setGeneration('DDR5'); setSpeedMHz(6000); setWarrantyMonths(36);
        } catch (err) {
            console.error(err);
            alert('Failed to save RAM.');
        }
    };

    return (
        <form onSubmit={handleSubmit} className="form-style">
            <h3>🧠 Add New RAM</h3>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                <input type="text"   placeholder="Name (e.g. Vengeance DDR5)"  value={name}           onChange={e => setName(e.target.value)}           required />
                <input type="text"   placeholder="Manufacturer (e.g. Corsair)" value={manufacturer}   onChange={e => setManufacturer(e.target.value)}   required />
                <input type="number" placeholder="Price"             step="0.01" value={price}          onChange={e => setPrice(e.target.value)}          required />
                <input type="number" placeholder="Capacity (GB)"                value={capacityGB}     onChange={e => setCapacityGB(e.target.value)}     required />
                <select value={generation} onChange={e => setGeneration(e.target.value)} required>
                    <option value="DDR5">DDR5</option>
                    <option value="DDR4">DDR4</option>
                    <option value="DDR3">DDR3</option>
                </select>
                <input type="number" placeholder="Speed (MHz)"                  value={speedMHz}       onChange={e => setSpeedMHz(e.target.value)}       required />
                <input type="number" placeholder="Warranty (months)"            value={warrantyMonths} onChange={e => setWarrantyMonths(e.target.value)} required />
                <button type="submit">Save RAM to Database</button>
            </div>
        </form>
    );
}

export default RamForm;