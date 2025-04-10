import React from 'react';
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import L from 'leaflet';

// Fix for default marker icons in react-leaflet
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon-2x.png',
  iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png',
});

const SeismicMap = ({ features }) => {
  if (!features || features.length === 0) {
    return null;
  }

  // Calculate center based on first feature
  const center = [
    features[0].properties.latitude,
    features[0].properties.longitude
  ];

  return (
    <MapContainer
      center={center}
      zoom={4}
      style={{ height: '500px', width: '100%' }}
    >
      <TileLayer
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
      />
      {features.map((feature) => (
        <Marker
          key={feature.id}
          position={[feature.properties.latitude, feature.properties.longitude]}
        >
          <Popup>
            <div>
              <h3>Magnitude: {feature.properties.mag}</h3>
              <p>Location: {feature.properties.place}</p>
              <p>Type: {feature.properties.mag_type}</p>
              <p>Time: {new Date(feature.properties.time).toLocaleString()}</p>
              <a href={feature.links.external_url} target="_blank" rel="noopener noreferrer">
                More Info
              </a>
            </div>
          </Popup>
        </Marker>
      ))}
    </MapContainer>
  );
};

export default SeismicMap;
