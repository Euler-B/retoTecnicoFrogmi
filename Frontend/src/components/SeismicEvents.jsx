import React, { useState } from 'react';
import {
  Container,
  Grid,
  Paper,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Pagination,
  Typography,
  Box,
  Card,
  CardContent,
  TextField,
  Button,
} from '@mui/material';
import { getFeatures } from '../services/api';
import SeismicMap from './SeismicMap';
import Welcome from './Welcome';

const magnitudeTypes = ['md', 'ml', 'ms', 'mw', 'me', 'mi', 'mb', 'mlg'];

const SeismicEvents = () => {
  const [features, setFeatures] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [magType, setMagType] = useState('');
  const [hasSearched, setHasSearched] = useState(false);

  // Get default dates (last 30 days)
  const getDefaultDates = () => {
    const end = new Date();
    const start = new Date();
    start.setDate(start.getDate() - 30);
    return {
      start: start.toISOString().split('T')[0],
      end: end.toISOString().split('T')[0]
    };
  };

  const [dates, setDates] = useState(getDefaultDates());

  const handleSearch = async () => {
    try {
      setLoading(true);
      setHasSearched(true);
      const params = {
        page,
        per_page: 10,
        ...(magType && { 'filters[mag_type]': magType }),
        'filters[start_date]': dates.start,
        'filters[end_date]': dates.end
      };
      
      const data = await getFeatures(params);
      setFeatures(data.features);
      setTotalPages(Math.ceil(data.pagination.total / data.pagination.per_page));
      setError(null);
    } catch (err) {
      setError('Error loading seismic events');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handlePageChange = (event, value) => {
    setPage(value);
    if (hasSearched) {
      handleSearch();
    }
  };

  const handleDateChange = (field) => (event) => {
    setDates(prev => ({
      ...prev,
      [field]: event.target.value
    }));
  };

  if (!hasSearched) {
    return (
      <>
        <Container maxWidth="lg" sx={{ py: 4 }}>
          <Paper sx={{ p: 2, mb: 4 }}>
            <Grid container spacing={2} alignItems="center">
              <Grid item xs={12} sm={3}>
                <TextField
                  label="Start Date"
                  type="date"
                  value={dates.start}
                  onChange={handleDateChange('start')}
                  fullWidth
                  InputLabelProps={{ shrink: true }}
                />
              </Grid>
              <Grid item xs={12} sm={3}>
                <TextField
                  label="End Date"
                  type="date"
                  value={dates.end}
                  onChange={handleDateChange('end')}
                  fullWidth
                  InputLabelProps={{ shrink: true }}
                />
              </Grid>
              <Grid item xs={12} sm={3}>
                <FormControl fullWidth>
                  <InputLabel>Magnitude Type</InputLabel>
                  <Select
                    value={magType}
                    onChange={(e) => setMagType(e.target.value)}
                    label="Magnitude Type"
                  >
                    <MenuItem value="">All</MenuItem>
                    {magnitudeTypes.map((type) => (
                      <MenuItem key={type} value={type}>
                        {type.toUpperCase()}
                      </MenuItem>
                    ))}
                  </Select>
                </FormControl>
              </Grid>
              <Grid item xs={12} sm={3}>
                <Button
                  variant="contained"
                  color="primary"
                  onClick={handleSearch}
                  fullWidth
                  sx={{ height: '56px' }}
                >
                  Search Events
                </Button>
              </Grid>
            </Grid>
          </Paper>
          <Welcome />
        </Container>
      </>
    );
  }

  if (loading) {
    return (
      <Container maxWidth="lg" sx={{ py: 4 }}>
        <Typography>Loading...</Typography>
      </Container>
    );
  }

  return (
    <Container maxWidth="lg" sx={{ py: 4 }}>
      <Paper sx={{ p: 2, mb: 4 }}>
        <Grid container spacing={2} alignItems="center">
          <Grid item xs={12} sm={3}>
            <TextField
              label="Start Date"
              type="date"
              value={dates.start}
              onChange={handleDateChange('start')}
              fullWidth
              InputLabelProps={{ shrink: true }}
            />
          </Grid>
          <Grid item xs={12} sm={3}>
            <TextField
              label="End Date"
              type="date"
              value={dates.end}
              onChange={handleDateChange('end')}
              fullWidth
              InputLabelProps={{ shrink: true }}
            />
          </Grid>
          <Grid item xs={12} sm={3}>
            <FormControl fullWidth>
              <InputLabel>Magnitude Type</InputLabel>
              <Select
                value={magType}
                onChange={(e) => setMagType(e.target.value)}
                label="Magnitude Type"
              >
                <MenuItem value="">All</MenuItem>
                {magnitudeTypes.map((type) => (
                  <MenuItem key={type} value={type}>
                    {type.toUpperCase()}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>
          </Grid>
          <Grid item xs={12} sm={3}>
            <Button
              variant="contained"
              color="primary"
              onClick={handleSearch}
              fullWidth
              sx={{ height: '56px' }}
            >
              Search Events
            </Button>
          </Grid>
        </Grid>
      </Paper>

      {error ? (
        <Typography color="error">{error}</Typography>
      ) : features.length > 0 ? (
        <>
          <Grid container spacing={3}>
            <Grid item xs={12}>
              <SeismicMap features={features} />
            </Grid>

            <Grid item xs={12}>
              <Typography variant="h6" gutterBottom sx={{ mt: 2 }}>
                Event List
              </Typography>
              {features.map((feature) => (
                <Card key={feature.id} sx={{ mb: 2 }}>
                  <CardContent>
                    <Typography variant="h6">
                      Magnitude {feature.properties.mag} ({feature.properties.mag_type})
                    </Typography>
                    <Typography color="textSecondary">
                      Location: {feature.properties.place}
                    </Typography>
                    <Typography color="textSecondary">
                      Time: {new Date(feature.properties.time).toLocaleString()}
                    </Typography>
                    <Box sx={{ mt: 1 }}>
                      <a
                        href={feature.links.external_url}
                        target="_blank"
                        rel="noopener noreferrer"
                      >
                        More Details
                      </a>
                    </Box>
                  </CardContent>
                </Card>
              ))}
            </Grid>

            <Grid item xs={12}>
              <Box display="flex" justifyContent="center" mt={2}>
                <Pagination
                  count={totalPages}
                  page={page}
                  onChange={handlePageChange}
                  color="primary"
                />
              </Box>
            </Grid>
          </Grid>
        </>
      ) : (
        <Typography>No events found for the selected criteria.</Typography>
      )}
    </Container>
  );
};

export default SeismicEvents;
