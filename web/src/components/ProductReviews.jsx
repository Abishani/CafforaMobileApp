import { useEffect, useState } from 'react'
import { useLocation, useNavigate } from 'react-router-dom'
import * as reviewsApi from '../api/reviews'
import { formatApiError } from '../api/client'
import { useApp } from '../context/AppContext'

function Stars({ rating, size = 'text-sm' }) {
  const filled = Math.round(Number(rating) || 0)
  return (
    <span className={`${size} tracking-[0.08em] text-[#b58900] whitespace-nowrap`} aria-label={`${Number(rating || 0).toFixed(1)} out of 5 stars`}>
      {'★'.repeat(filled)}
      <span className="text-latte">{'★'.repeat(5 - filled)}</span>
    </span>
  )
}

function ReviewItem({ review, expanded = false }) {
  return (
    <article className={expanded ? 'border-b border-latte pb-4 last:border-0' : 'flex flex-col gap-1'}>
      <div className="flex items-center justify-between gap-2">
        <span className="font-sans font-semibold text-espresso text-xs truncate">{review.userName}</span>
        <Stars rating={review.rating} size="text-xs" />
      </div>
      <p className={`font-sans text-mocha text-xs leading-relaxed ${expanded ? '' : 'line-clamp-2'}`}>
        {review.comment}
      </p>
      {expanded && review.createdAt && (
        <time className="font-sans text-[11px] text-mocha" dateTime={review.createdAt}>
          {new Date(review.createdAt).toLocaleDateString()}
        </time>
      )}
    </article>
  )
}

export default function ProductReviews({ product }) {
  const { user, token, refreshProducts } = useApp()
  const navigate = useNavigate()
  const location = useLocation()
  const [open, setOpen] = useState(false)
  const [showForm, setShowForm] = useState(false)
  const [reviews, setReviews] = useState([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)
  const [rating, setRating] = useState(0)
  const [comment, setComment] = useState('')
  const [submitting, setSubmitting] = useState(false)
  const [success, setSuccess] = useState(null)

  const averageRating = Number(product.averageRating) || 0
  const reviewCount = Number(product.reviewCount) || 0
  const topReviews = product.topReviews ?? []

  useEffect(() => {
    if (!open) return undefined
    const onKeyDown = (event) => {
      if (event.key === 'Escape') setOpen(false)
    }
    document.addEventListener('keydown', onKeyDown)
    const previousOverflow = document.body.style.overflow
    document.body.style.overflow = 'hidden'
    return () => {
      document.removeEventListener('keydown', onKeyDown)
      document.body.style.overflow = previousOverflow
    }
  }, [open])

  const loadReviews = async ({ prefillForm = false } = {}) => {
    setLoading(true)
    setError(null)
    try {
      const nextReviews = (await reviewsApi.listReviews(product.id)) ?? []
      setReviews(nextReviews)
      if (prefillForm && user) {
        const ownReview = nextReviews.find((review) => String(review.userId) === String(user.id))
        if (ownReview) {
          setRating(ownReview.rating)
          setComment(ownReview.comment)
        }
      }
    } catch (err) {
      setError(formatApiError(err))
    } finally {
      setLoading(false)
    }
  }

  const showReviews = (withForm = false) => {
    if (withForm && !user) {
      navigate('/auth', { state: { from: location } })
      return
    }
    setShowForm(withForm)
    setSuccess(null)
    setError(null)
    setOpen(true)
    loadReviews({ prefillForm: withForm })
  }

  const submitReview = async (event) => {
    event.preventDefault()
    setError(null)
    setSuccess(null)
    if (rating < 1 || rating > 5) {
      setError('Please choose a rating from 1 to 5 stars.')
      return
    }
    if (!comment.trim()) {
      setError('Please write a review before submitting.')
      return
    }

    setSubmitting(true)
    try {
      await reviewsApi.saveReview(product.id, { rating, comment: comment.trim() }, token)
      setComment('')
      setRating(0)
      setSuccess('Your review has been saved.')
      await Promise.all([loadReviews(), refreshProducts()])
    } catch (err) {
      setError(formatApiError(err))
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <>
      <section className="border-t border-latte flex flex-col gap-3 px-5 py-4 w-full" aria-label={`Reviews for ${product.name}`}>
        <div className="flex items-center justify-between gap-3 w-full">
          <div className="flex items-center gap-2 min-w-0">
            <Stars rating={averageRating} />
            <span className="font-display font-bold text-espresso text-sm">{averageRating.toFixed(1)}</span>
            <span className="font-sans text-mocha text-xs">({reviewCount})</span>
          </div>
          <button type="button" onClick={() => showReviews(false)} className="font-sans font-semibold text-rust text-xs whitespace-nowrap">
            View more
          </button>
        </div>

        <div className="flex flex-col gap-3">
          {topReviews.length === 0 ? (
            <p className="font-sans text-mocha text-xs">No reviews yet. Be the first to share your thoughts.</p>
          ) : (
            topReviews.map((review) => <ReviewItem key={review.id} review={review} />)
          )}
        </div>

        <button
          type="button"
          onClick={() => showReviews(true)}
          className="border border-rust border-solid rounded-lg py-2 w-full font-sans font-bold text-rust text-xs hover:bg-blush transition-colors"
        >
          Add Review
        </button>
      </section>

      {open && (
        <div
          className="fixed inset-0 z-50 bg-espresso/60 flex items-center justify-center p-4"
          role="presentation"
          onMouseDown={(event) => {
            if (event.target === event.currentTarget) setOpen(false)
          }}
        >
          <div
            className="bg-white flex flex-col max-h-[90vh] overflow-hidden rounded-2xl shadow-2xl w-full max-w-3xl"
            role="dialog"
            aria-modal="true"
            aria-labelledby={`reviews-title-${product.id}`}
          >
            <div className="border-b border-latte flex items-start justify-between gap-4 p-5">
              <div className="flex gap-4 min-w-0">
                <img src={product.imageUrl} alt={product.name} className="rounded-xl size-20 object-cover shrink-0" />
                <div className="min-w-0">
                  <h2 id={`reviews-title-${product.id}`} className="font-display font-extrabold text-espresso text-xl">
                    {product.name}
                  </h2>
                  <p className="font-sans text-mocha text-sm mt-1">{product.description}</p>
                  <p className="font-sans font-semibold text-rust text-xs mt-2">
                    {product.categoryName} · ${Number(product.price).toFixed(2)}
                    {product.calories ? ` · ${product.calories} calories` : ''}
                  </p>
                  <div className="flex items-center gap-2 mt-2">
                    <Stars rating={averageRating} />
                    <span className="font-sans font-bold text-espresso text-sm">{averageRating.toFixed(1)}</span>
                    <span className="font-sans text-mocha text-xs">from {reviewCount} {reviewCount === 1 ? 'review' : 'reviews'}</span>
                  </div>
                </div>
              </div>
              <button
                type="button"
                onClick={() => setOpen(false)}
                aria-label="Close reviews"
                className="font-sans text-mocha text-2xl leading-none"
              >
                ×
              </button>
            </div>

            <div className="overflow-y-auto p-5">
              {showForm && (
                <form onSubmit={submitReview} className="bg-cream flex flex-col gap-4 p-4 rounded-xl mb-6">
                  <div>
                    <p className="font-display font-bold text-espresso text-base">Review this product</p>
                    <p className="font-sans text-mocha text-xs mt-1">Submitting again updates your previous review.</p>
                  </div>
                  <fieldset>
                    <legend className="font-sans font-semibold text-espresso text-xs mb-2">Your rating</legend>
                    <div className="flex gap-1">
                      {[1, 2, 3, 4, 5].map((value) => (
                        <button
                          key={value}
                          type="button"
                          onClick={() => setRating(value)}
                          aria-label={`${value} star${value === 1 ? '' : 's'}`}
                          aria-pressed={rating === value}
                          className={`text-2xl ${value <= rating ? 'text-[#b58900]' : 'text-latte'}`}
                        >
                          ★
                        </button>
                      ))}
                    </div>
                  </fieldset>
                  <div>
                    <label htmlFor={`review-comment-${product.id}`} className="font-sans font-semibold text-espresso text-xs">
                      Your review
                    </label>
                    <textarea
                      id={`review-comment-${product.id}`}
                      value={comment}
                      onChange={(event) => setComment(event.target.value)}
                      maxLength={1000}
                      rows={4}
                      placeholder="What did you like about it?"
                      className="bg-white border border-latte border-solid mt-2 p-3 rounded-lg w-full font-sans text-sm text-espresso focus:outline-none focus:border-rust"
                    />
                    <p className="font-sans text-mocha text-[11px] text-right">{comment.length}/1000</p>
                  </div>
                  {error && <p className="font-sans text-[#b3261e] text-sm" role="alert">{error}</p>}
                  {success && <p className="font-sans text-[#498500] text-sm" role="status">{success}</p>}
                  <button
                    type="submit"
                    disabled={submitting}
                    className="bg-rust rounded-lg py-2.5 font-sans font-bold text-white text-sm disabled:opacity-60"
                  >
                    {submitting ? 'Saving…' : 'Save Review'}
                  </button>
                </form>
              )}

              <div className="flex flex-col gap-4">
                <h3 className="font-display font-bold text-espresso text-lg">All reviews</h3>
                {loading ? (
                  <p className="font-sans text-mocha text-sm">Loading reviews…</p>
                ) : error && !showForm ? (
                  <p className="font-sans text-[#b3261e] text-sm" role="alert">{error}</p>
                ) : reviews.length === 0 ? (
                  <p className="font-sans text-mocha text-sm">No reviews have been added yet.</p>
                ) : (
                  reviews.map((review) => <ReviewItem key={review.id} review={review} expanded />)
                )}
              </div>
            </div>
          </div>
        </div>
      )}
    </>
  )
}
