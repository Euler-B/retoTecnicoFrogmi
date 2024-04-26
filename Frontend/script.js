const filterButton = document.getElementById('filterButton');
const magTypeSelect = document.getElementById('magType');
const sismosContainer = document.getElementById('sismosContainer');

filterButton.addEventListener('click', () => {
  const magType = magTypeSelect.value;
  fetch(`http://127.0.0.1:3000/v1/sismos?filters[mag_type]=${magType}`)
    .then(response => response.json())
    .then(data => {
      displaySismos(data);
    })
    .catch(error => {
      console.error('Ocurrió un error:', error);
    });
});

function displaySismos(data) {
  sismosContainer.innerHTML = '';

  data.data.forEach(sismo => {
    const sismoCard = document.createElement('div');
    sismoCard.className = 'sismoCard';

    const title = document.createElement('h2');
    title.textContent = sismo.attributes.title;
    sismoCard.appendChild(title);

    const magnitude = document.createElement('p');
    magnitude.textContent = `Magnitud: ${sismo.attributes.magnitude}`;
    sismoCard.appendChild(magnitude);

    const place = document.createElement('p');
    place.textContent = `Lugar: ${sismo.attributes.place}`;
    sismoCard.appendChild(place);

    const time = document.createElement('p');
    time.textContent = `Fecha y hora: ${sismo.attributes.time}`;
    sismoCard.appendChild(time);

    sismosContainer.appendChild(sismoCard);
  });

  const pagination = document.createElement('div');
  pagination.className = 'pagination';

  for (let i = 1; i <= data.pagination.total_pages; i++) {
    const pageLink = document.createElement('a');
    pageLink.href = `?page=${i}`;
    pageLink.textContent = i;
    pagination.appendChild(pageLink);
  }

  sismosContainer.appendChild(pagination);
}