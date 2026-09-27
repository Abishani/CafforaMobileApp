import { useEffect, useState } from 'react'
import { Link, useLocation } from 'react-router-dom'
import { useApp } from '../context/AppContext'
import * as reviewsApi from '../api/reviews'
import { formatApiError, getFieldErrors } from '../api/client'

const TOP_COUNT = 5
const COMMENT_MAX = 500 // matches the backend ReviewRequest @Size
const RATING_LABELS = ['Poor', 'Fair', 'Good', 'Very good', 'Excellent']

const formatDate = (iso) => {
  if (!iso) return ''
  const d = new Date(iso)
  return Number.isNaN(d.getTime()) ? '' : d.toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' })
}

function Stars({ rating, className = 'text-base' }) {
  const rounded = Math.round(rating)
  return (
    <span role="img" aria-label={`Rated ${rating} out of 5`} className={`flex gap-0.5 leading-none ${className}`}>
      {[1, 2, 3, 4, 5].map((n) => (
        <span key={n} aria-hidden="true" className={n <= rounded ? 'text-rust' : 'text-latte'}>
          ★
        </span>
      ))}
    </span>
  )
}

function StarRatingInput({ value, onChange, error, describedBy }) {
  const [hover, setHover] = useState(0)
  const shown = hover || value
  return (
    <fieldset className="flex flex-col gap-2 items-start w-full" aria-describedby={describedBy}>
      <legend className="font-sans font-semibold text-[#3d2b1f] text-[13px] mb-2">Rating</legend>
      <div className="flex gap-1 items-center" onMouseLeave={() => setHover(0)}>
        {[1, 2, 3, 4, 5].map((n) => (
          <label
            key={n}
            className="cursor-pointer rounded text-[28px] leading-none has-[:focus-visible]:outline has-[:focus-visible]:outline-2 has-[:focus-visible]:outline-rust"
            onMouseEnter={() => setHover(n)}
          >
            <input
              type="radio"
              name="review-rating"
              value={n}
              checked={value === n}
              onChange={() => onChange(n)}
              aria-invalid={error ? true : undefined}
              className="sr-only"
            />
            <span aria-hidden="true" className={n <= shown ? 'text-rust' : 'text-latte'}>
              ★
            </span>
            <span className="sr-only">
              {n} {n === 1 ? 'star' : 'stars'} — {RATING_LABELS[n - 1]}
            </span>
          </label>
        ))}
        <span className="font-sans text-mocha text-[13px] ml-2" aria-hidden="true">
          {shown ? RATING_LABELS[shown - 1] : 'Select a rating'}
        </span>
      </div>
    </fieldset>
  )
}

function ReviewCard({ review }) {
  return (
    <li className="bg-white border border-latte border-solid flex flex-col gap-3 items-start p-5 rounded-2xl w-full min-w-0">
      <Stars rating={review.rating} />
      <p className="font-sans text-espresso text-sm leading-relaxed break-words w-full whitespace-pre-line">
        “{review.comment}”
      </p>
      <div className="flex flex-wrap gap-x-2 gap-y-1 items-baseline w-full min-w-0">
        <p className="font-sans font-bold text-espresso text-[13px] break-words min-w-0">— {review.reviewerName}</p>
        {review.createdAt && (
          <time dateTime={review.createdAt} className="font-sans text-mocha text-[12px]">
            {formatDate(review.createdAt)}
          </time>
        )}
      </div>
    </li>
  )
}

function ReviewForm({ onSubmitted }) {
  const { token, logout } = useApp()
  const [rating, setRating] = useState(0)
  const [comment, setComment] = useState('')
  const [errors, setErrors] = useState({})
  const [formError, setFormError] = useState(null)
  const [success, setSuccess] = useState(null)
  const [submitting, setSubmitting] = useState(false)

  const handleSubmit = async (e) => {
    e.preventDefault()
    if (submitting) return
    setFormError(null)
    setSuccess(null)

    const trimmed = comment.trim()
    const next = {}
    if (!rating) next.rating = 'Please select a rating.'
    if (!trimmed) next.comment = 'Please enter your review.'
    else if (trimmed.length > COMMENT_MAX) next.comment = `Your review must be at most ${COMMENT_MAX} characters.`
    setErrors(next)
    if (Object.keys(next).length) {
      if (next.rating) document.querySelector('input[name="review-rating"]')?.focus()
      else document.getElementById('review-comment')?.focus()
      return
    }

    setSubmitting(true)
    try {
      await reviewsApi.createReview({ rating, comment: trimmed }, token)
      setRating(0)
      setComment('')
      setErrors({})
      setSuccess('Thank you! Your review has been posted.')
      onSubmitted()
    } catch (err) {
      if (err?.status === 401) {
        logout()
        setFormError('Your session has expired. Please sign in again to write a review.')
        return
      }
      const server = getFieldErrors(err)
      if (server.rating || server.comment) {
        const sentence = (msg) => (msg && !msg.endsWith('.') ? `${msg}.` : msg)
        setErrors({ rating: sentence(server.rating), comment: sentence(server.comment) })
      } else {
        setFormError(formatApiError(err))
      }
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <form onSubmit={handleSubmit} noValidate className="flex flex-col gap-5 items-start w-full">
      <div className="flex flex-col gap-1 items-start w-full">
        <StarRatingInput
          value={rating}
          onChange={(n) => {
            setRating(n)
            setErrors((prev) => ({ ...prev, rating: undefined }))
            setSuccess(null)
          }}
          error={errors.rating}
          describedBy={errors.rating ? 'review-rating-error' : undefined}
        />
        {errors.rating && (
          <p id="review-rating-error" className="font-sans text-[13px] text-[#b3261e]">
            {errors.rating}
          </p>
        )}
      </div>

      <div className="flex flex-col gap-2 items-start w-full">
        <label htmlFor="review-comment" className="font-sans font-semibold text-[#3d2b1f] text-[13px]">
          Your Review
        </label>
        <textarea
          id="review-comment"
          rows={4}
          value={comment}
          maxLength={COMMENT_MAX}
          onChange={(e) => {
            setComment(e.target.value)
            setErrors((prev) => ({ ...prev, comment: undefined }))
            setSuccess(null)
          }}
          placeholder="Tell us about your coffee, food or service…"
          aria-invalid={errors.comment ? true : undefined}
          aria-describedby={`review-comment-count${errors.comment ? ' review-comment-error' : ''}`}
          className={`border ${errors.comment ? 'border-[#b3261e]' : 'border-latte'} border-solid p-3.5 rounded-lg w-full font-sans text-sm text-espresso placeholder:text-mocha focus:outline-none focus:border-rust resize-y`}
        />
        <div className="flex gap-3 items-start justify-between w-full">
          <p id="review-comment-error" className="font-sans text-[13px] text-[#b3261e]">
            {errors.comment}
          </p>
          <p id="review-comment-count" className="font-sans text-mocha text-[11px] shrink-0">
            {comment.length}/{COMMENT_MAX}
          </p>
        </div>
      </div>

      {formError && (
        <p className="font-sans text-sm text-[#b3261e] whitespace-pre-line" role="alert">
          {formError}
        </p>
      )}
      <p className="font-sans text-sm text-[#498500] empty:hidden" role="status">
        {success}
      </p>

      <button
        type="submit"
        disabled={submitting}
        aria-busy={submitting || undefined}
        className="bg-espresso flex items-center justify-center py-3.5 rounded-xl shrink-0 w-full font-sans font-bold text-[15px] text-white hover:opacity-90 transition-opacity disabled:opacity-60 disabled:cursor-wait"
      >
        {submitting ? 'Submitting…' : 'Submit Review'}
      </button>
    </form>
  )
}

export default function ReviewsSection() {
  const { user } = useApp()
  const location = useLocation()
  const [reviews, setReviews] = useState([])
  const [total, setTotal] = useState(0)
  const [average, setAverage] = useState(0)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  const [expanded, setExpanded] = useState(false)
  const [loadingMore, setLoadingMore] = useState(false)

  // Fetch the top 5 only, or every review once the list has been expanded.
  const load = async (all) => {
    const data = await reviewsApi.listReviews(all ? {} : { limit: TOP_COUNT })
    setReviews(data?.reviews ?? [])
    setTotal(data?.totalCount ?? 0)
    setAverage(data?.averageRating ?? 0)
  }

  useEffect(() => {
    load(false)
      .catch((err) => setError(formatApiError(err)))
      .finally(() => setLoading(false))
  }, [])

  const toggleExpanded = async () => {
    if (expanded) {
      setExpanded(false)
      return
    }
    if (reviews.length < total) {
      setLoadingMore(true)
      setError(null)
      try {
        await load(true)
      } catch (err) {
        setError(formatApiError(err))
        return
      } finally {
        setLoadingMore(false)
      }
    }
    setExpanded(true)
  }

  const refreshAfterSubmit = () => {
    load(expanded).catch((err) => setError(formatApiError(err)))
  }

  const visible = expanded ? reviews : reviews.slice(0, TOP_COUNT)

  return (
    <section
      aria-labelledby="reviews-heading"
      className="bg-white border-latte border-t border-solid flex flex-col gap-10 items-start px-6 lg:px-16 py-20 w-full"
      data-name="customer-reviews"
    >
      <div className="flex items-end justify-between w-full flex-wrap gap-4">
        <div className="flex flex-col gap-2 items-start">
          <h2 id="reviews-heading" className="font-display font-extrabold text-espresso text-[32px]">
            Customer Reviews
          </h2>
          <p className="font-sans text-mocha text-base">What our regulars are saying about Caffora.</p>
        </div>
        {total > 0 && (
          <div className="bg-cream flex gap-3 items-center px-4 py-2.5 rounded-xl shrink-0">
            <Stars rating={average} className="text-lg" />
            <p className="font-display font-bold text-espresso text-base whitespace-nowrap">{average.toFixed(1)}/5</p>
            <p className="font-sans text-mocha text-[13px] whitespace-nowrap">
              {total} {total === 1 ? 'review' : 'reviews'}
            </p>
          </div>
        )}
      </div>

      <div className="flex flex-col lg:flex-row gap-10 items-start w-full">
        <div className="flex flex-col gap-6 items-start flex-1 min-w-0 w-full">
          {loading ? (
            <p className="font-sans text-mocha text-sm">Loading reviews…</p>
          ) : error && reviews.length === 0 ? (
            <p className="font-sans text-sm text-[#b3261e]" role="alert">
              {error}
            </p>
          ) : reviews.length === 0 ? (
            <p className="font-sans text-mocha text-sm">No reviews yet — be the first to share your experience.</p>
          ) : (
            <>
              <ul id="reviews-list" className="grid grid-cols-1 md:grid-cols-2 gap-4 w-full">
                {visible.map((review) => (
                  <ReviewCard key={review.id} review={review} />
                ))}
              </ul>
              {error && (
                <p className="font-sans text-sm text-[#b3261e]" role="alert">
                  {error}
                </p>
              )}
              {total > TOP_COUNT && (
                <button
                  type="button"
                  onClick={toggleExpanded}
                  disabled={loadingMore}
                  aria-expanded={expanded}
                  aria-controls="reviews-list"
                  className="border border-rust border-solid flex items-center justify-center px-5 py-2.5 rounded-xl shrink-0 font-sans font-semibold text-rust text-sm whitespace-nowrap hover:bg-blush transition-colors disabled:opacity-60 disabled:cursor-wait"
                >
                  {loadingMore
                    ? 'Loading reviews…'
                    : expanded
                      ? 'Show Less Reviews'
                      : `View More Reviews (${total - TOP_COUNT})`}
                </button>
              )}
            </>
          )}
        </div>

        <div className="bg-cream flex flex-col gap-5 items-start p-6 rounded-2xl shrink-0 w-full lg:w-[400px]">
          <h3 className="font-display font-bold text-espresso text-xl">Write a Review</h3>
          {user ? (
            <ReviewForm onSubmitted={refreshAfterSubmit} />
          ) : (
            <div className="flex flex-col gap-4 items-start w-full">
              <p className="font-sans text-mocha text-sm">Sign in to write a review.</p>
              <Link
                to="/auth"
                state={{ from: location }}
                className="bg-espresso flex items-center justify-center py-3 rounded-xl w-full font-sans font-bold text-sm text-white hover:opacity-90 transition-opacity"
              >
                Sign In to Write a Review
              </Link>
            </div>
          )}
        </div>
      </div>
    </section>
  )
}
