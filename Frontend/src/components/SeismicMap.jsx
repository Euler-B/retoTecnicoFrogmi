import React, { useMemo } from 'react';
import { MapContainer, TileLayer, CircleMarker, Popup } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';

const getMarkerColor = (mag) => {
  if (!mag) return '#888';
  if (mag < 3) return '#4caf50';
  if (mag < 5) return '#ff9800';
  if (mag < 7) return '#f44336';
  return '#b71c1c';
};

const getMarkerRadius = (mag) => {
  if (!mag) return 6;
  return Math.max(6, mag * 5);
};

const SeismicMap = ({ features }) => {
  const validFeatures = useMemo(() => {
    if (!features) return [];
    return features.filter((f) => {
      const coords = f.attributes?.coordinates;
      return coords?.latitude != null && coords?.longitude != null;
    });
  }, [features]);

  if (validFeatures.length === 0) {
    return null;
  }

  const first = validFeatures[0].attributes.coordinates;

  return (
    <div style={{ height: '500px', width: '100%', marginBottom: '16px' }}>
      <MapContainer
        center={[first.latitude, first.longitude]}
        zoom={4}
        style={{ height: '100%', width: '100%', borderRadius: '8px' }}
        scrollWheelZoom={true}
      >
        <TileLayer
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
        />
        {validFeatures.map((feature) => {
          const coords = feature.attributes.coordinates;
          const mag = feature.attributes.magnitude;
          return (
            <CircleMarker
              key={feature.id}
              center={[coords.latitude, coords.longitude]}
              radius={getMarkerRadius(mag)}
              pathOptions={{
                fillColor: getMarkerColor(mag),
                color: '#333',
                weight: 1,
                fillOpacity: 0.8,
              }}
            >
              <Popup>
                <div>
                  <h3>Magnitude: {mag}</h3>
                  <p>Location: {feature.attributes.place}</p>
                  <p>Type: {feature.attributes.mag_type}</p>
                  <p>Time: {new Date(feature.attributes.time).toLocaleString()}</p>
                  <a href={feature.links.external_url} target="_blank" rel="noopener noreferrer">
                    More Info
                  </a>
                </div>
              </Popup>
            </CircleMarker>
          );
        })}
      </MapContainer>
    </div>
  );
};

export default SeismicMap;
