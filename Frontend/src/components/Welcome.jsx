import React from 'react';
import {
  Container,
  Typography,
  Paper,
  Box,
} from '@mui/material';

const Welcome = () => {
  return (
    <Container maxWidth="md">
      <Box sx={{ py: 8 }}>
        <Paper elevation={3} sx={{ p: 4, textAlign: 'center' }}>
          <Typography variant="h3" component="h1" gutterBottom>
            Seismic Events Explorer
          </Typography>
          <Typography variant="h5" color="text.secondary" paragraph>
            Discover and analyze seismic activity around the world
          </Typography>
          <Typography variant="body1" paragraph>
            This application allows you to:
          </Typography>
          <Box sx={{ textAlign: 'left', maxWidth: 500, mx: 'auto' }}>
            <Typography component="ul" sx={{ pl: 2 }}>
              <li>View seismic events on an interactive map</li>
              <li>Filter events by date range (default: last 30 days)</li>
              <li>Filter by magnitude type (md, ml, ms, mw, etc.)</li>
              <li>Access detailed information about each event</li>
            </Typography>
          </Box>
          <Typography variant="body2" sx={{ mt: 4 }} color="text.secondary">
            Use the search filters above to start exploring seismic events
          </Typography>
        </Paper>
      </Box>
    </Container>
  );
};

export default Welcome;
