import { apiRequest } from './client'

export function listReviews(productId) {
  return apiRequest(`/products/${productId}/reviews`)
}

export function saveReview(productId, { rating, comment }, token) {
  return apiRequest(`/products/${productId}/reviews`, {
    method: 'POST',
    body: { rating, comment },
    token,
  })
}
