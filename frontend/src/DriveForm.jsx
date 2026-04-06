import { useState } from 'react';

function DriveForm({ onDriveAdded, api }) {
    const [name,           setName]           = useState('');
    const [manufacturer,   setManufacturer]   = useState('');
    const [price,          setPrice]          = useState('');
    const [storageGB,      setStorageGB]      = useState(1000);
    const [driveType,      setDriveType]      = useState('SSD');
    const [readSpeedMBs,   setReadSpeedMBs]   = useState(3500);
    const [writeSpeedMBs,  setWriteSpeedMBs]  = useState(3000);
    const [warrantyMonths, setWarrantyMonths] = useState(36);

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            const res = await api.post('/drives', {
                name,
                manufacturer,
                price:          parseFloat(price),
                storageGB:      parseInt(storageGB),
                driveType,
                readSpeedMBs:   parseInt(readSpeedMBs),
                writeSpeedMBs:  parseInt(writeSpeedMBs),
                warrantyMonths: parseInt(warrantyMonths),
            });
            alert('Drive saved!');
            onDriveAdded(res.data);
            setName(''); setManufacturer(''); setPrice(''); setStorageGB(1000);
            setDriveType('SSD'); setReadSpeedMBs(3500); setWriteSpeedMBs(3000); setWarrantyMonths(36);
        } catch (err) {
            console.error(err);
            alert('Failed to save Drive.');
        }
    };

    return (
        <form onSubmit={handleSubmit} className="form-style">
            <h3>💾 Add New Drive</h3>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                <input type="text"   placeholder="Name (e.g. 970 EVO Plus)"    value={name}           onChange={e => setName(e.target.value)}           required />
                <input type="text"   placeholder="Manufacturer (e.g. Samsung)" value={manufacturer}   onChange={e => setManufacturer(e.target.value)}   required />
                <input type="number" placeholder="Price"             step="0.01" value={price}          onChange={e => setPrice(e.target.value)}          required />
                <input type="number" placeholder="Storage (GB)"                 value={storageGB}      onChange={e => setStorageGB(e.target.value)}      required />
                <select value={driveType} onChange={e => setDriveType(e.target.value)} required>
                    <option value="SSD">SSD</option>
                    <option value="HDD">HDD</option>
                </select>
                <input type="number" placeholder="Read Speed (MB/s)"           value={readSpeedMBs}   onChange={e => setReadSpeedMBs(e.target.value)}   required />
                <input type="number" placeholder="Write Speed (MB/s)"          value={writeSpeedMBs}  onChange={e => setWriteSpeedMBs(e.target.value)}  required />
                <input type="number" placeholder="Warranty (months)"           value={warrantyMonths} onChange={e => setWarrantyMonths(e.target.value)} required />
                <button type="submit">Save Drive to Database</button>
            </div>
        </form>
    );
}

export default DriveForm;