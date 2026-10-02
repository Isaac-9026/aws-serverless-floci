const fileInput = document.getElementById('file-input');
const uploadBtn = document.getElementById('upload-btn');
const statusText = document.getElementById('status-text');
const refreshBtn = document.getElementById('refresh-btn');

//Subir archivo a S3
uploadBtn.addEventListener('click', async () => {
    const file = fileInput.files[0];
    if (!file) {
        statusText.textContent = 'Selecciona un archivo primero.';
        return;
    }

    statusText.textContent = `Subiendo ${file.name}...`;

    try {
        const response = await fetch('/upload', {
            method: 'POST',
            headers: {
                'X-File-Name': encodeURIComponent(file.name)
            },
            body: file
        });

        if (response.ok) {
            statusText.textContent = `Archivo "${file.name}" subido con éxito.`;
            fileInput.value = '';
            setTimeout(fetchStats, 2000);
        } else {
            throw new Error('Fallo al subir');
        }
    } catch (err) {
        statusText.textContent = 'Error al subir el archivo.';
    }
});

//Obtener las estadisticas de la DB
async function fetchStats() {
    try {
        const res = await fetch('/stats');
        const data = await res.json();
        document.getElementById('total-archivos').textContent = data.total_archivos;
        document.getElementById('total-peso').textContent = `${data.peso_total_mb} MB`;
    } catch (err) {
        console.error('Error al obtener estadIsticas:', err);
    }
}

refreshBtn.addEventListener('click', fetchStats);

//Cargar estadisticas iniciales
fetchStats();
