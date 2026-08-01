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
import { getFeatures, createComment } from '../services/api';
import SeismicMap from './SeismicMap';
import Welcome from './Welcome';

const magnitudeTypes = ['md', 'ml', 'ms', 'mw', 'me', 'mi', 'mb', 'mlg'];

const SeismicEvents = () => {
  const [features, setFeatures] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [total, setTotal] = useState(0);
  const [magType, setMagType] = useState('');
  const [hasSearched, setHasSearched] = useState(false);
  const [commentInputs, setCommentInputs] = useState({});
  const [commentSubmitting, setCommentSubmitting] = useState({});
  const [commentFeedback, setCommentFeedback] = useState({});

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

  const handleSearch = async (pageOverride = null) => {
    try {
      setLoading(true);
      setHasSearched(true);
      const currentPage = typeof pageOverride === 'number' ? pageOverride : page;
      const params = {
        page: currentPage,
        per_page: 10,
        ...(magType && { 'filters[mag_type]': magType }),
        'filters[start_date]': dates.start,
        'filters[end_date]': dates.end
      };
      
      const data = await getFeatures(params);
      setFeatures(data.data);
      setTotal(data.pagination.total);
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
    handleSearch(value);
  };

  const handleDateChange = (field) => (event) => {
    setDates(prev => ({
      ...prev,
      [field]: event.target.value
    }));
  };

  const handleSubmitComment = async (featureId) => {
    const body = (commentInputs[featureId] || '').trim();
    if (!body) return;

    setCommentSubmitting(prev => ({ ...prev, [featureId]: true }));
    setCommentFeedback(prev => ({ ...prev, [featureId]: null }));
    try {
      await createComment(featureId, body);
      setCommentInputs(prev => ({ ...prev, [featureId]: '' }));
      setCommentFeedback(prev => ({ ...prev, [featureId]: { type: 'success', message: 'Comment added' } }));
    } catch (err) {
      const message = err.response?.data?.errors?.join(', ') || err.response?.data?.error || 'Failed to add comment';
      setCommentFeedback(prev => ({ ...prev, [featureId]: { type: 'error', message } }));
    } finally {
      setCommentSubmitting(prev => ({ ...prev, [featureId]: false }));
    }
  };

  if (!hasSearched) {
    return (
      <>
        <Container maxWidth="lg" sx={{ py: 4 }}>
          <Paper sx={{ p: 2, mb: 4 }}>
            <Grid container spacing={2} alignItems="center">
              <Grid size={{ xs: 12, sm: 3 }}>
                <TextField
                  label="Start Date"
                  type="date"
                  value={dates.start}
                  onChange={handleDateChange('start')}
                  fullWidth
                  InputLabelProps={{ shrink: true }}
                />
              </Grid>
              <Grid size={{ xs: 12, sm: 3 }}>
                <TextField
                  label="End Date"
                  type="date"
                  value={dates.end}
                  onChange={handleDateChange('end')}
                  fullWidth
                  InputLabelProps={{ shrink: true }}
                />
              </Grid>
              <Grid size={{ xs: 12, sm: 3 }}>
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
              <Grid size={{ xs: 12, sm: 3 }}>
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
          <Grid size={{ xs: 12, sm: 3 }}>
            <TextField
              label="Start Date"
              type="date"
              value={dates.start}
              onChange={handleDateChange('start')}
              fullWidth
              InputLabelProps={{ shrink: true }}
            />
          </Grid>
          <Grid size={{ xs: 12, sm: 3 }}>
            <TextField
              label="End Date"
              type="date"
              value={dates.end}
              onChange={handleDateChange('end')}
              fullWidth
              InputLabelProps={{ shrink: true }}
            />
          </Grid>
          <Grid size={{ xs: 12, sm: 3 }}>
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
          <Grid size={{ xs: 12, sm: 3 }}>
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
          <Box sx={{ mb: 2, textAlign: 'center' }}>
            <Typography variant="body1" color="text.secondary">
              Showing {features.length} of {total.toLocaleString()} events &mdash; Page {page} of {totalPages}
            </Typography>
          </Box>

          <Grid container spacing={3}>
            <Grid size={12}>
              <SeismicMap features={features} />
            </Grid>

            <Grid size={12}>
              <Typography variant="h6" gutterBottom sx={{ mt: 2 }}>
                Event List
              </Typography>
              {features.map((feature) => (
                <Card key={feature.id} sx={{ mb: 2 }}>
                  <CardContent>
                    <Typography variant="h6">
                      Magnitude {feature.attributes.magnitude} ({feature.attributes.mag_type})
                    </Typography>
                    <Typography color="textSecondary">
                      Location: {feature.attributes.place}
                    </Typography>
                    <Typography color="textSecondary">
                      Time: {new Date(feature.attributes.time).toLocaleString()}
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

                    <Box sx={{ mt: 2, display: 'flex', gap: 1, alignItems: 'flex-start' }}>
                      <TextField
                        size="small"
                        placeholder="Add a comment..."
                        value={commentInputs[feature.id] || ''}
                        onChange={(e) =>
                          setCommentInputs(prev => ({ ...prev, [feature.id]: e.target.value }))
                        }
                        fullWidth
                      />
                      <Button
                        variant="contained"
                        size="small"
                        onClick={() => handleSubmitComment(feature.id)}
                        disabled={
                          commentSubmitting[feature.id] ||
                          !(commentInputs[feature.id] || '').trim()
                        }
                        sx={{ minWidth: '100px', height: '40px' }}
                      >
                        {commentSubmitting[feature.id] ? 'Sending...' : 'Comment'}
                      </Button>
                    </Box>
                    {commentFeedback[feature.id] && (
                      <Typography
                        variant="body2"
                        color={commentFeedback[feature.id].type === 'success' ? 'success.main' : 'error'}
                        sx={{ mt: 1 }}
                      >
                        {commentFeedback[feature.id].message}
                      </Typography>
                    )}
                  </CardContent>
                </Card>
              ))}
            </Grid>

            <Grid size={12}>
              <Box display="flex" justifyContent="center" mt={2} pb={6}>
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
