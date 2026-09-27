import { apiRequest } from './client'

/** Public. Sorted by rating desc, newest first. Omit `limit` to get every review. */
export function listReviews({ limit } = {}) {
  return apiRequest('/reviews', { query: limit ? { limit } : undefined })
}

/** Requires a signed-in user; the backend takes the author from the token. */
export function createReview({ rating, comment }, token) {
  return apiRequest('/reviews', { method: 'POST', body: { rating, comment }, token })
}
