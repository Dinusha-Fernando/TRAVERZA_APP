/**
 * TRAVERZA TypeScript API Client
 * Generated & curated SDK for TRAVERZA Sri Lanka Connected Travel Platform
 */

export interface SystemHealth {
  status: string;
  app: string;
  env: string;
  corridor: string;
  version: string;
}

export type BookingStatus =
  | 'DRAFT'
  | 'FEASIBILITY_CHECKED'
  | 'REQUEST_SUBMITTED'
  | 'PROVIDER_ACCEPTED'
  | 'CONFIRMED'
  | 'IN_PROGRESS'
  | 'COMPLETED'
  | 'CANCELLED'
  | 'EXCEPTION';

export interface QuoteSnapshot {
  id: string;
  trip_id: string;
  listing_id: string;
  organization_id: string;
  amount_minor: number;
  currency: string;
  cancellation_terms: string;
  expires_at: string;
  captured_at: string;
}

export interface ServiceBooking {
  id: string;
  trip_id: string;
  organization_id: string;
  itinerary_item_id: string;
  quote_snapshot_id: string;
  status: BookingStatus;
  amount_minor: number;
  currency: string;
  response_deadline_at: string;
  confirmed_at: string | null;
  cancellation_reason?: string | null;
  voucher_code?: string | null;
  signed_voucher_token?: string | null;
  payment_reference?: string | null;
  refund_amount_minor?: number | null;
}

export interface BookingItemSummary {
  booking_id: string;
  itinerary_item_id: string;
  title: string;
  category: string;
  status: BookingStatus;
  amount_minor: number;
  currency: string;
  voucher_code?: string | null;
  response_deadline_at?: string | null;
}

export interface TripBookingSummary {
  trip_id: string;
  overall_status: 'DRAFT' | 'REQUEST_SUBMITTED' | 'PARTIALLY_CONFIRMED' | 'CONFIRMED' | 'CANCELLED';
  total_bookable_items: number;
  requested_count: number;
  accepted_count: number;
  confirmed_count: number;
  cancelled_count: number;
  total_committed_lkr: number;
  items: BookingItemSummary[];
}

export interface Trip {
  id: string;
  traveler_id: string;
  title: string;
  start_date: string;
  end_date: string;
  status?: string;
}

export interface CommunityPost {
  id: string;
  author_id: string;
  author_name: string;
  author_avatar?: string | null;
  author_role: 'TRAVELLER' | 'LOCAL_CREATOR' | 'LICENSED_GUIDE' | 'SLTDA_OFFICIAL';
  post_type: 'MOMENT' | 'FIELD_REPORT' | 'QUESTION' | 'ROAD_ADVISORY';
  district_name: string;
  title: string;
  content: string;
  media_type?: 'IMAGE' | 'VIDEO' | 'CAROUSEL' | null;
  media_urls: string[];
  video_duration_seconds?: number | null;
  like_count: number;
  comment_count: number;
  created_at: string;
}

export interface ChatMessage {
  id: string;
  conversation_id: string;
  sender_id: string;
  sender_name: string;
  client_message_id: string;
  message_type: 'TEXT' | 'PHOTO' | 'VIDEO' | 'PLACE_SNIPPET' | 'ITINERARY_SNIPPET';
  delivery_status: 'SENDING' | 'SENT' | 'DELIVERED' | 'READ';
  text_content: string;
  payload_data?: Record<string, unknown> | null;
  created_at: string;
}

export interface TraverzaClientOptions {
  baseUrl: string;
  authToken?: string;
  fetchFn?: typeof fetch;
}

export class TraverzaApiClient {
  private baseUrl: string;
  private authToken?: string;
  private fetchFn: typeof fetch;

  constructor(options: TraverzaClientOptions) {
    this.baseUrl = options.baseUrl.replace(/\/+$/, '');
    this.authToken = options.authToken;
    this.fetchFn = options.fetchFn || fetch.bind(globalThis);
  }

  public setAuthToken(token: string) {
    this.authToken = token;
  }

  private async request<T>(path: string, options: RequestInit = {}): Promise<T> {
    const url = `${this.baseUrl}${path.startsWith('/') ? path : `/${path}`}`;
    const headers = new Headers(options.headers);

    if (!headers.has('Content-Type') && options.body) {
      headers.set('Content-Type', 'application/json');
    }
    if (this.authToken && !headers.has('Authorization')) {
      headers.set('Authorization', `Bearer ${this.authToken}`);
    }

    const response = await this.fetchFn(url, { ...options, headers });
    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Traverza API Error [${response.status}]: ${errorText}`);
    }
    return response.json() as Promise<T>;
  }

  // System & Health
  public async getHealth(): Promise<SystemHealth> {
    return this.request<SystemHealth>('/health');
  }

  // Trips & Planning
  public async getTrip(tripId: string): Promise<Trip> {
    return this.request<Trip>(`/api/v1/trips/${tripId}`);
  }

  public async getTripBookingSummary(tripId: string): Promise<TripBookingSummary> {
    return this.request<TripBookingSummary>(`/api/v1/trips/${tripId}/booking-summary`);
  }

  // Quotes & Bookings
  public async createQuote(tripId: string, listingId: string, validityHours = 24): Promise<QuoteSnapshot> {
    return this.request<QuoteSnapshot>(`/api/v1/trips/${tripId}/quotes`, {
      method: 'POST',
      body: JSON.stringify({ listing_id: listingId, validity_hours: validityHours }),
    });
  }

  public async createBooking(tripId: string, itineraryItemId: string, quoteSnapshotId: string): Promise<ServiceBooking> {
    return this.request<ServiceBooking>('/api/v1/bookings', {
      method: 'POST',
      body: JSON.stringify({
        trip_id: tripId,
        itinerary_item_id: itineraryItemId,
        quote_snapshot_id: quoteSnapshotId,
      }),
    });
  }

  public async confirmPayment(bookingId: string, paymentReference: string, paymentMethod = 'CARD'): Promise<ServiceBooking> {
    return this.request<ServiceBooking>(`/api/v1/bookings/${bookingId}/confirm-payment`, {
      method: 'POST',
      body: JSON.stringify({
        payment_reference: paymentReference,
        payment_method: paymentMethod,
      }),
    });
  }

  public async cancelBooking(bookingId: string, reason: string): Promise<Record<string, unknown>> {
    return this.request<Record<string, unknown>>(`/api/v1/bookings/${bookingId}/cancel`, {
      method: 'POST',
      body: JSON.stringify({ reason }),
    });
  }

  // Community & Intelligence
  public async getCommunityPulse(district?: string): Promise<CommunityPost[]> {
    const query = district ? `?district=${encodeURIComponent(district)}` : '';
    return this.request<CommunityPost[]>(`/api/v1/community/posts${query}`);
  }

  // Travel Messenger
  public async sendMessage(
    conversationId: string,
    clientMessageId: string,
    content: string,
    messageType: 'TEXT' | 'PHOTO' | 'VIDEO' = 'TEXT',
    payloadData?: Record<string, unknown>
  ): Promise<ChatMessage> {
    return this.request<ChatMessage>(`/api/v1/messenger/conversations/${conversationId}/messages`, {
      method: 'POST',
      body: JSON.stringify({
        client_message_id: clientMessageId,
        message_type: messageType,
        text_content: content,
        payload_data: payloadData,
      }),
    });
  }
}
