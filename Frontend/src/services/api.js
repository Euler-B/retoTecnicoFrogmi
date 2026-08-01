import axios from 'axios';

const API_BASE_URL = 'http://localhost:3000/v1';

export const getFeatures = async (params = {}) => {
  try {
    // Convert dates to the format expected by the backend if needed
    if (params['filters[start_date]']) {
      params['filters[start_date]'] = new Date(params['filters[start_date]']).toISOString();
    }
    if (params['filters[end_date]']) {
      params['filters[end_date]'] = new Date(params['filters[end_date]']).toISOString();
    }

    const response = await axios.get(`${API_BASE_URL}/sismos`, { params });
    return response.data;
  } catch (error) {
    console.error('Error fetching features:', error);
    throw error;
  }
};

export const createComment = async (featureId, body) => {
  try {
    const response = await axios.post(
      `${API_BASE_URL}/sismos/${featureId}/comments`,
      { body }
    );
    return response.data;
  } catch (error) {
    console.error('Error creating comment:', error);
    throw error;
  }
};
