// export default App;

// import { useEffect, useState } from 'react';
// import { legal_smart_contract_backend } from '../../declarations/legal-smart-contract-backend';

// function App() {
//   const [documents, setDocuments] = useState([]);
//   const [name, setName] = useState('');
//   const [content, setContent] = useState(null);
//   const [docType, setDocType] = useState('');
//   const [mimeType, setMimeType] = useState('');
  
//   useEffect(() => {
//     fetchDocuments();
//   }, []);

//   async function fetchDocuments() {
//     const metadata = await legal_smart_contract_backend.getDocumentMetadata();
//     setDocuments(metadata);
//   }

//   async function handleUpload(event) {
//     event.preventDefault();
//     if (!name || !content || !docType || !mimeType) {
//       alert('All fields are required');
//       return;
//     }

//     const reader = new FileReader();
//     reader.readAsArrayBuffer(content);
//     reader.onloadend = async () => {
//       const contentArray = [new Uint8Array(reader.result)];
//       const result = await legal_smart_contract_backend.storeDocument(name, contentArray, docType, mimeType);
//       if (result.ok) {
//         alert('Document uploaded successfully!');
//         fetchDocuments();
//       } else {
//         alert(result.err);
//       }
//     };
//   }

//   async function handleDelete(id) {
//     const result = await legal_smart_contract_backend.deleteDocument(id);
//     if (result.ok) {
//       alert('Document deleted successfully!');
//       fetchDocuments();
//     } else {
//       alert(result.err);
//     }
//   }

//   return (
//     <main>
//       <h1>Legal Document Storage</h1>
//       <form onSubmit={handleUpload}>
//         <input type="text" placeholder="Document Name" value={name} onChange={(e) => setName(e.target.value)} required />
//         <input type="file" onChange={(e) => { setContent(e.target.files[0]); setMimeType(e.target.files[0].type); }} required />
//         <input type="text" placeholder="Document Type" value={docType} onChange={(e) => setDocType(e.target.value)} required />
//         <button type="submit">Upload Document</button>
//       </form>

//       <h2>Stored Documents</h2>
//       <ul>
//         {documents.map((doc) => (
//           <li key={doc.id}>
//             {doc.name} - {doc.metadata.documentType} ({doc.metadata.status})
//             <button onClick={() => handleDelete(doc.id)}>Delete</button>
//           </li>
//         ))}
//       </ul>
//     </main>
//   );
// }

// export default App;

import { useEffect, useState } from 'react';
import { legal_smart_contract_backend } from '../../declarations/legal-smart-contract-backend';

function App() {
  const [documents, setDocuments] = useState([]);
  const [name, setName] = useState('');
  const [content, setContent] = useState(null);
  const [docType, setDocType] = useState('');
  const [mimeType, setMimeType] = useState('');
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState({ text: '', type: '' });

  useEffect(() => {
    fetchDocuments();
  }, []);

  async function fetchDocuments() {
    setLoading(true);
    try {
      const metadata = await legal_smart_contract_backend.getDocumentMetadata();
      setDocuments(metadata);
    } catch (error) {
      showMessage('Error fetching documents', 'error');
    }
    setLoading(false);
  }

  async function handleUpload(event) {
    event.preventDefault();
    if (!name || !content || !docType || !mimeType) {
      showMessage('All fields are required', 'error');
      return;
    }

    setLoading(true);
    const reader = new FileReader();
    reader.readAsArrayBuffer(content);
    reader.onloadend = async () => {
      const contentArray = [new Uint8Array(reader.result)];
      try {
        const result = await legal_smart_contract_backend.storeDocument(name, contentArray, docType, mimeType);
        if (result.ok) {
          showMessage('Document uploaded successfully!', 'success');
          fetchDocuments();
        } else {
          showMessage(result.err, 'error');
        }
      } catch (error) {
        showMessage('Error uploading document', 'error');
      }
      setLoading(false);
    };
  }

  async function handleDelete(id) {
    setLoading(true);
    try {
      const result = await legal_smart_contract_backend.deleteDocument(id);
      if (result.ok) {
        showMessage('Document deleted successfully!', 'success');
        fetchDocuments();
      } else {
        showMessage(result.err, 'error');
      }
    } catch (error) {
      showMessage('Error deleting document', 'error');
    }
    setLoading(false);
  }

  function showMessage(text, type) {
    setMessage({ text, type });
    setTimeout(() => setMessage({ text: '', type: '' }), 4000);
  }

  return (
    <div className="max-w-4xl mx-auto p-6 bg-white shadow-md rounded-lg">
      <h1 className="text-3xl font-bold text-gray-800 text-center mb-6">Legal Document Storage</h1>

      {message.text && (
        <div className={`p-3 mb-4 text-white rounded ${message.type === 'error' ? 'bg-red-500' : 'bg-green-500'}`}>
          {message.text}
        </div>
      )}

      <form onSubmit={handleUpload} className="bg-gray-100 p-4 rounded-lg shadow">
        <input
          type="text"
          placeholder="Document Name"
          className="w-full p-2 mb-2 border rounded"
          value={name}
          onChange={(e) => setName(e.target.value)}
          required
        />
        <input
          type="file"
          className="w-full p-2 mb-2 border rounded"
          onChange={(e) => {
            setContent(e.target.files[0]);
            setMimeType(e.target.files[0].type);
          }}
          required
        />
        <input
          type="text"
          placeholder="Document Type"
          className="w-full p-2 mb-2 border rounded"
          value={docType}
          onChange={(e) => setDocType(e.target.value)}
          required
        />
        <button
          type="submit"
          className="w-full bg-blue-500 text-white p-2 rounded hover:bg-blue-600 transition"
          disabled={loading}
        >
          {loading ? 'Uploading...' : 'Upload Document'}
        </button>
      </form>

      <h2 className="text-2xl font-semibold text-gray-800 mt-6 mb-4">Stored Documents</h2>

      {loading ? (
        <p className="text-gray-500">Loading documents...</p>
      ) : (
        <ul className="divide-y divide-gray-200">
          {documents.map((doc) => (
            <li key={doc.id} className="p-4 flex justify-between items-center bg-gray-50 rounded-lg shadow-sm">
              <span className="text-gray-700">{doc.name} - {doc.metadata.documentType} ({doc.metadata.status})</span>
              <button
                onClick={() => handleDelete(doc.id)}
                className="bg-red-500 text-white px-3 py-1 rounded hover:bg-red-600 transition"
              >
                Delete
              </button>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}

export default App;
