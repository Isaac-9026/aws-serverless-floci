const tablaCuerpo = document.getElementById('tabla-cuerpo');

async function cargarTabla() {
    try {
        const res = await fetch('/items');
        if (!res.ok) throw new Error('Error al obtener datos');
        
        const documentos = await res.json();
        
        tablaCuerpo.innerHTML = '';
        
        if (documentos.length === 0) {
            tablaCuerpo.innerHTML = '<tr><td colspan="4">No hay documentos registrados aún.</td></tr>';
            return;
        }

        documentos.forEach(doc => {
            const tr = document.createElement('tr');
            
            // Nombre
            const tdNombre = document.createElement('td');
            tdNombre.textContent = doc.nombre_archivo;
            tr.appendChild(tdNombre);
            
            // Tamaño
            const tdTamanio = document.createElement('td');
            tdTamanio.textContent = doc.tamanio_bytes;
            tr.appendChild(tdTamanio);
            
            // Fecha
            const tdFecha = document.createElement('td');
            tdFecha.textContent = doc.fecha_subida;
            tr.appendChild(tdFecha);
            
            // Estado
            const tdEstado = document.createElement('td');
            tdEstado.textContent = doc.estado;
            tr.appendChild(tdEstado);
            
            tablaCuerpo.appendChild(tr);
        });
    } catch (err) {
        console.error(err);
        tablaCuerpo.innerHTML = '<tr><td colspan="4">Error al cargar los registros.</td></tr>';
    }
}

cargarTabla();
