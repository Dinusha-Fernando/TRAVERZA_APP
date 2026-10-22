'use client';

import React, { useState } from 'react';
import Link from 'next/link';

interface PostMedia {
  id: string;
  mediaUrl: string;
  mediaType: string;
}

interface PostComment {
  id: string;
  authorName: string;
  authorBadge?: string;
  commentText: string;
  helpfulVotes: number;
  isAcceptedAnswer: boolean;
  createdAt: string;
}

interface CommunityPost {
  id: string;
  authorName: string;
  authorBadge: 'LICENSED_GUIDE' | 'VERIFIED_VISITOR' | 'LOCAL_EXPERT' | 'COMMUNITY_MEMBER';
  authorAvatar: string;
  districtId: string;
  districtName: string;
  destinationId?: string;
  destinationName?: string;
  postType: 'PHOTO' | 'FIELD_REPORT' | 'QUESTION' | 'LOCAL_NOTE';
  caption: string;
  media: PostMedia[];
  publishedAt: string;
  observedAt?: string;
  expiresInHours?: number;
  helpfulCount: number;
  commentCount: number;
  trustLabel: string;
  comments: PostComment[];
  isQuestionResolved?: boolean;
}

const SRI_LANKA_DISTRICTS = [
  { id: 'all', name: 'All 25 Districts' },
  { id: 'matale', name: 'Matale (Central)' },
  { id: 'badulla', name: 'Badulla (Uva)' },
  { id: 'kandy', name: 'Kandy (Central)' },
  { id: 'nuwara-eliya', name: 'Nuwara Eliya (Central)' },
  { id: 'galle', name: 'Galle (Southern)' },
  { id: 'colombo', name: 'Colombo (Western)' },
  { id: 'polonnaruwa', name: 'Polonnaruwa (N.Central)' },
  { id: 'anuradhapura', name: 'Anuradhapura (N.Central)' },
  { id: 'jaffna', name: 'Jaffna (Northern)' },
  { id: 'trincomalee', name: 'Trincomalee (Eastern)' },
  { id: 'batticaloa', name: 'Batticaloa (Eastern)' },
  { id: 'hambantota', name: 'Hambantota (Southern)' },
  { id: 'matara', name: 'Matara (Southern)' },
  { id: 'ratnapura', name: 'Ratnapura (Sabaragamuwa)' },
];

const INITIAL_POSTS: CommunityPost[] = [
  {
    id: 'post-sigiriya-sunrise',
    authorName: 'Duminda Bandara',
    authorBadge: 'LICENSED_GUIDE',
    authorAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
    districtId: 'matale',
    districtName: 'Matale',
    destinationId: 'sigiriya-rock-fortress',
    destinationName: 'Sigiriya Lion Rock',
    postType: 'FIELD_REPORT',
    caption: 'Lion Rock stairs are clear and dry this morning! Arrived at 06:45 AM. Recommend ascending before 09:30 AM to beat midday heat and high-season staircase queues. Wind speed at summit is a mild 12 km/h.',
    media: [
      {
        id: 'm1',
        mediaUrl: 'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?auto=format&fit=crop&w=1200&q=80',
        mediaType: 'image',
      },
    ],
    publishedAt: '2 hours ago',
    observedAt: 'Today, 06:45 AM',
    expiresInHours: 4,
    helpfulCount: 42,
    commentCount: 6,
    trustLabel: 'Verified by Licensed Cultural Guide',
    comments: [
      {
        id: 'c1',
        authorName: 'Sarah Jenkins',
        authorBadge: 'VERIFIED_VISITOR',
        commentText: 'Thanks Duminda! Is the water bottle ban still enforced past the terrace gate?',
        helpfulVotes: 7,
        isAcceptedAnswer: false,
        createdAt: '1 hour ago',
      },
      {
        id: 'c2',
        authorName: 'Duminda Bandara',
        authorBadge: 'LICENSED_GUIDE',
        commentText: 'Reusable aluminium bottles are permitted. Single-use plastic covers are removed at the security checkpoint.',
        helpfulVotes: 19,
        isAcceptedAnswer: true,
        createdAt: '45 mins ago',
      },
    ],
  },
  {
    id: 'post-knuckles-rain',
    authorName: 'Kavinda Perera',
    authorBadge: 'LOCAL_EXPERT',
    authorAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
    districtId: 'matale',
    districtName: 'Matale',
    destinationId: 'knuckles-corbets-gap',
    destinationName: "Corbet's Gap, Knuckles",
    postType: 'FIELD_REPORT',
    caption: 'Sudden afternoon cloudburst over Deanston and Corbet’s Gap. Moderate leech activity on the trail and slippery granite sections. Bring leech socks and high-traction waterproof boots if trekking today.',
    media: [
      {
        id: 'm2',
        mediaUrl: 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?auto=format&fit=crop&w=1200&q=80',
        mediaType: 'image',
      },
    ],
    publishedAt: '3 hours ago',
    observedAt: 'Today, 11:15 AM',
    expiresInHours: 3,
    helpfulCount: 29,
    commentCount: 3,
    trustLabel: 'Real-time Community Field Report',
    comments: [
      {
        id: 'c3',
        authorName: 'Markus Weber',
        commentText: 'Are 4WD vehicles needed to reach the trailhead from Hunnasgiriya?',
        helpfulVotes: 4,
        isAcceptedAnswer: false,
        createdAt: '2 hours ago',
      },
      {
        id: 'c4',
        authorName: 'Kavinda Perera',
        authorBadge: 'LOCAL_EXPERT',
        commentText: 'High clearance or 4WD strongly advised after heavy rain as the last 4km unpaved estate track has fresh ruts.',
        helpfulVotes: 12,
        isAcceptedAnswer: true,
        createdAt: '1 hour ago',
      },
    ],
  },
  {
    id: 'post-ella-nine-arch-qa',
    authorName: 'Elena Rostova',
    authorBadge: 'VERIFIED_VISITOR',
    authorAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
    districtId: 'badulla',
    districtName: 'Badulla',
    destinationId: 'nine-arch-bridge-ella',
    destinationName: 'Nine Arch Bridge',
    postType: 'QUESTION',
    caption: 'What is the most reliable afternoon train schedule across Nine Arch Bridge this week? We want to catch the blue train passing with good photography light without blocking track workers.',
    media: [
      {
        id: 'm3',
        mediaUrl: 'https://images.unsplash.com/photo-1589308078059-be1415eab4c3?auto=format&fit=crop&w=1200&q=80',
        mediaType: 'image',
      },
    ],
    publishedAt: '5 hours ago',
    helpfulCount: 31,
    commentCount: 4,
    trustLabel: 'Active Destination Q&A',
    isQuestionResolved: true,
    comments: [
      {
        id: 'c5',
        authorName: 'Niroshan Senanayake',
        authorBadge: 'LICENSED_GUIDE',
        commentText: 'The 15:20 Colombo-Badulla express is currently crossing between 15:35 and 15:45 PM. Stand on the tea estate slopes on the north ridge for optimal golden-hour backlighting.',
        helpfulVotes: 28,
        isAcceptedAnswer: true,
        createdAt: '3 hours ago',
      },
    ],
  },
  {
    id: 'post-galle-fort-sunset',
    authorName: 'Ayesha De Silva',
    authorBadge: 'LOCAL_EXPERT',
    authorAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
    districtId: 'galle',
    districtName: 'Galle',
    destinationId: 'galle-dutch-fort',
    destinationName: 'Galle Dutch Fort',
    postType: 'LOCAL_NOTE',
    caption: 'Walk the ramparts from Flag Rock to the Lighthouse around 17:15. Local artisan gelato shop down Pedlar Street is serving fresh passion-fruit sorbet sourced from Uva orchards.',
    media: [
      {
        id: 'm4',
        mediaUrl: 'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?auto=format&fit=crop&w=1200&q=80',
        mediaType: 'image',
      },
    ],
    publishedAt: 'Yesterday',
    helpfulCount: 54,
    commentCount: 2,
    trustLabel: 'Locally Loved Place Note',
    comments: [],
  },
  {
    id: 'post-minneriya-gathering',
    authorName: 'Wild Ceylon Safaris',
    authorBadge: 'LOCAL_EXPERT',
    authorAvatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=200&q=80',
    districtId: 'polonnaruwa',
    districtName: 'Polonnaruwa',
    destinationId: 'minneriya-national-park',
    destinationName: 'Minneriya National Park',
    postType: 'FIELD_REPORT',
    caption: 'Over 130 elephants gathered around the central reservoir grass beds by 16:00! Water levels are receding nicely. Drivers adhering strictly to the 25-meter standoff rule for matriarch herds with newborn calves.',
    media: [
      {
        id: 'm5',
        mediaUrl: 'https://images.unsplash.com/photo-1557050543-4d5f4e07ef46?auto=format&fit=crop&w=1200&q=80',
        mediaType: 'image',
      },
    ],
    publishedAt: '4 hours ago',
    observedAt: 'Today, 16:20 PM',
    expiresInHours: 6,
    helpfulCount: 68,
    commentCount: 5,
    trustLabel: 'Verified Wildlife Operator Report',
    comments: [
      {
        id: 'c6',
        authorName: 'David Miller',
        commentText: 'Do we need afternoon permits booked in advance at the gate?',
        helpfulVotes: 9,
        isAcceptedAnswer: true,
        createdAt: '2 hours ago',
      },
    ],
  },
];

export default function CommunityPage() {
  const [posts, setPosts] = useState<CommunityPost[]>(INITIAL_POSTS);
  const [selectedType, setSelectedType] = useState<string>('ALL');
  const [selectedDistrict, setSelectedDistrict] = useState<string>('all');
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [savedPostIds, setSavedPostIds] = useState<Set<string>>(new Set(['post-sigiriya-sunrise']));
  const [helpfulPostIds, setHelpfulPostIds] = useState<Set<string>>(new Set());
  
  // TripGraph Validation Modal State
  const [validatingPost, setValidatingPost] = useState<CommunityPost | null>(null);
  const [tripGraphResult, setTripGraphResult] = useState<{
    feasible: boolean;
    roadBufferMins: number;
    recommendedWindow: string;
    notes: string[];
  } | null>(null);

  // Provider Inquiry Modal State
  const [inquiryPost, setInquiryPost] = useState<CommunityPost | null>(null);
  const [inquiryDate, setInquiryDate] = useState<string>('2026-10-25');
  const [inquiryGuests, setInquiryGuests] = useState<number>(2);
  const [inquirySent, setInquirySent] = useState<boolean>(false);

  // Create Moment Modal State
  const [showCreateModal, setShowCreateModal] = useState<boolean>(false);
  const [newCaption, setNewCaption] = useState<string>('');
  const [newType, setNewType] = useState<'PHOTO' | 'FIELD_REPORT' | 'QUESTION' | 'LOCAL_NOTE'>('PHOTO');
  const [newDistrict, setNewDistrict] = useState<string>('matale');
  const [newDestination, setNewDestination] = useState<string>('Sigiriya Lion Rock');

  // Filter posts
  const filteredPosts = posts.filter((p) => {
    if (selectedType !== 'ALL' && p.postType !== selectedType) return false;
    if (selectedDistrict !== 'all' && p.districtId !== selectedDistrict) return false;
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase();
      const matchText =
        p.caption.toLowerCase().includes(q) ||
        p.authorName.toLowerCase().includes(q) ||
        p.districtName.toLowerCase().includes(q) ||
        (p.destinationName && p.destinationName.toLowerCase().includes(q));
      if (!matchText) return false;
    }
    return true;
  });

  const toggleHelpful = (id: string) => {
    setHelpfulPostIds((prev) => {
      const next = new Set(prev);
      const isAlready = next.has(id);
      if (isAlready) {
        next.delete(id);
      } else {
        next.add(id);
      }
      setPosts((current) =>
        current.map((p) =>
          p.id === id ? { ...p, helpfulCount: isAlready ? p.helpfulCount - 1 : p.helpfulCount + 1 } : p
        )
      );
      return next;
    });
  };

  const toggleSave = (id: string) => {
    setSavedPostIds((prev) => {
      const next = new Set(prev);
      if (next.has(id)) {
        next.delete(id);
      } else {
        next.add(id);
      }
      return next;
    });
  };

  const handleValidateItinerary = (post: CommunityPost) => {
    setValidatingPost(post);
    // Simulating TripGraph corridor checks
    setTimeout(() => {
      setTripGraphResult({
        feasible: true,
        roadBufferMins: 25,
        recommendedWindow: '06:30 - 09:30 AM (Morning Ascent)',
        notes: [
          `Corridor transit to ${post.destinationName || post.districtName} calculated via A6 / B615 Highway.`,
          '25-minute buffer allocated for highland winding road sections and wildlife crossings.',
          'Opening window verified: 07:00 AM - 17:30 PM. No scheduling conflicts with Day 1 itinerary.',
        ],
      });
    }, 400);
  };

  const handleCreatePost = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newCaption.trim()) return;

    const districtObj = SRI_LANKA_DISTRICTS.find((d) => d.id === newDistrict);

    const created: CommunityPost = {
      id: `post-${Date.now()}`,
      authorName: 'Dinusha Jayasuriya',
      authorBadge: 'COMMUNITY_MEMBER',
      authorAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
      districtId: newDistrict,
      districtName: districtObj ? districtObj.name.split(' ')[0] : 'Sri Lanka',
      destinationName: newDestination.trim() || undefined,
      postType: newType,
      caption: newCaption,
      media: [
        {
          id: `m-${Date.now()}`,
          mediaUrl: 'https://images.unsplash.com/photo-1546708973-b339540b5162?auto=format&fit=crop&w=1200&q=80',
          mediaType: 'image',
        },
      ],
      publishedAt: 'Just now',
      observedAt: newType === 'FIELD_REPORT' ? 'Just now' : undefined,
      expiresInHours: newType === 'FIELD_REPORT' ? 4 : undefined,
      helpfulCount: 1,
      commentCount: 0,
      trustLabel: newType === 'FIELD_REPORT' ? 'Recent Community Field Report' : 'Community Moment',
      comments: [],
    };

    setPosts([created, ...posts]);
    setNewCaption('');
    setShowCreateModal(false);
  };

  return (
    <div style={{ maxWidth: '1280px', margin: '0 auto', padding: '36px 24px', minHeight: '90vh' }}>
      {/* 1. Header Banner */}
      <div
        style={{
          background: 'linear-gradient(135deg, rgba(7, 59, 92, 0.95) 0%, rgba(8, 126, 139, 0.85) 100%)',
          borderRadius: 'var(--radius-lg)',
          padding: '36px 40px',
          color: '#ffffff',
          marginBottom: '32px',
          boxShadow: '0 12px 36px rgba(7, 59, 92, 0.18)',
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          flexWrap: 'wrap',
          gap: '24px',
        }}
      >
        <div style={{ maxWidth: '720px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '12px' }}>
            <span
              style={{
                background: 'rgba(255, 255, 255, 0.2)',
                padding: '4px 12px',
                borderRadius: 'var(--radius-pill)',
                fontSize: '0.8rem',
                fontWeight: 700,
                letterSpacing: '0.05em',
                textTransform: 'uppercase',
              }}
            >
              Island Atlas · Community Layer
            </span>
            <span
              style={{
                background: 'rgba(34, 184, 207, 0.25)',
                padding: '4px 12px',
                borderRadius: 'var(--radius-pill)',
                fontSize: '0.8rem',
                fontWeight: 600,
                color: '#E0F7FA',
              }}
            >
              Privacy Safe · EXIF Stripped
            </span>
          </div>
          <h1
            style={{
              fontSize: '2.5rem',
              fontWeight: 800,
              fontFamily: 'var(--font-heading)',
              letterSpacing: '-0.02em',
              marginBottom: '10px',
              lineHeight: 1.15,
            }}
          >
            TRAVERZA Community Pulse
          </h1>
          <p style={{ fontSize: '1.05rem', lineHeight: 1.6, color: 'rgba(255, 255, 255, 0.9)' }}>
            Real moments, time-stamped trail conditions, place Q&A, and verified local notes across Sri Lanka&apos;s 25 districts.
            Discover a place, check route feasibility with TripGraph, and connect directly with verified providers.
          </p>
          <div style={{ display: 'flex', gap: '24px', marginTop: '18px', flexWrap: 'wrap' }}>
            <div>
              <span style={{ fontSize: '1.3rem', fontWeight: 800, color: '#A5F3FC' }}>25</span>
              <span style={{ fontSize: '0.85rem', color: 'rgba(255,255,255,0.8)', marginLeft: '6px' }}>Districts</span>
            </div>
            <div>
              <span style={{ fontSize: '1.3rem', fontWeight: 800, color: '#A5F3FC' }}>100%</span>
              <span style={{ fontSize: '0.85rem', color: 'rgba(255,255,255,0.8)', marginLeft: '6px' }}>Atlas Verified Tagging</span>
            </div>
            <div>
              <span style={{ fontSize: '1.3rem', fontWeight: 800, color: '#A5F3FC' }}>0 GPS Trace</span>
              <span style={{ fontSize: '0.85rem', color: 'rgba(255,255,255,0.8)', marginLeft: '6px' }}>Privacy Protected</span>
            </div>
          </div>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
          <button
            onClick={() => setShowCreateModal(true)}
            className="btn"
            style={{
              background: '#ffffff',
              color: 'var(--color-primary)',
              fontWeight: 700,
              padding: '14px 28px',
              fontSize: '1.0rem',
              borderRadius: 'var(--radius-md)',
              boxShadow: '0 6px 20px rgba(0,0,0,0.12)',
              display: 'flex',
              alignItems: 'center',
              gap: '8px',
              border: 'none',
              cursor: 'pointer',
            }}
          >
            <span style={{ fontSize: '1.2rem' }}>➕</span> Share a Moment
          </button>
          <Link
            href="/atlas"
            style={{
              color: '#ffffff',
              fontSize: '0.88rem',
              fontWeight: 600,
              textAlign: 'center',
              textDecoration: 'underline',
              opacity: 0.88,
            }}
          >
            🧭 Open Island Atlas Catalogue →
          </Link>
        </div>
      </div>

      {/* 2. Search & Filter Bar */}
      <div
        style={{
          background: 'var(--color-surface)',
          border: '1px solid var(--color-border)',
          borderRadius: 'var(--radius-md)',
          padding: '16px 20px',
          marginBottom: '28px',
          display: 'flex',
          flexDirection: 'column',
          gap: '16px',
          boxShadow: 'var(--shadow-sm)',
        }}
      >
        <div style={{ display: 'flex', gap: '16px', flexWrap: 'wrap', alignItems: 'center' }}>
          <div style={{ flex: 1, minWidth: '260px', position: 'relative' }}>
            <input
              type="text"
              placeholder="Search by destination, trail, district, or author..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              style={{
                width: '100%',
                padding: '12px 16px 12px 42px',
                borderRadius: 'var(--radius-sm)',
                border: '1px solid var(--color-border)',
                fontSize: '0.95rem',
                outline: 'none',
              }}
            />
            <span style={{ position: 'absolute', left: '14px', top: '12px', fontSize: '1.1rem', color: 'var(--color-text-muted)' }}>
              🔍
            </span>
          </div>

          {/* District Dropdown */}
          <div style={{ minWidth: '220px' }}>
            <select
              value={selectedDistrict}
              onChange={(e) => setSelectedDistrict(e.target.value)}
              style={{
                width: '100%',
                padding: '12px 16px',
                borderRadius: 'var(--radius-sm)',
                border: '1px solid var(--color-border)',
                fontSize: '0.92rem',
                fontWeight: 600,
                color: 'var(--color-text)',
                backgroundColor: 'var(--color-surface)',
                outline: 'none',
                cursor: 'pointer',
              }}
            >
              {SRI_LANKA_DISTRICTS.map((d) => (
                <option key={d.id} value={d.id}>
                  {d.name}
                </option>
              ))}
            </select>
          </div>
        </div>

        {/* Type Filter Chips */}
        <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap' }}>
          {[
            { id: 'ALL', label: 'All Moments' },
            { id: 'FIELD_REPORT', label: '⏱️ Field Reports' },
            { id: 'QUESTION', label: '❓ Questions & Q&A' },
            { id: 'LOCAL_NOTE', label: '💡 Local Notes' },
            { id: 'PHOTO', label: '📸 Visual Moments' },
          ].map((type) => (
            <button
              key={type.id}
              onClick={() => setSelectedType(type.id)}
              style={{
                padding: '8px 18px',
                borderRadius: 'var(--radius-pill)',
                fontSize: '0.86rem',
                fontWeight: 700,
                border: selectedType === type.id ? '2px solid var(--color-secondary)' : '1px solid var(--color-border)',
                background: selectedType === type.id ? 'rgba(8, 126, 139, 0.1)' : 'var(--color-surface)',
                color: selectedType === type.id ? 'var(--color-secondary)' : 'var(--color-text-muted)',
                cursor: 'pointer',
                transition: 'all 0.15s ease',
              }}
            >
              {type.label}
            </button>
          ))}
        </div>
      </div>

      {/* 3. Featured Place Signal Card */}
      <div
        style={{
          background: 'linear-gradient(135deg, rgba(8, 126, 139, 0.08) 0%, rgba(34, 184, 207, 0.04) 100%)',
          border: '1.5px solid rgba(8, 126, 139, 0.25)',
          borderRadius: 'var(--radius-md)',
          padding: '20px 24px',
          marginBottom: '32px',
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          flexWrap: 'wrap',
          gap: '16px',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
          <div
            style={{
              width: '46px',
              height: '46px',
              borderRadius: '12px',
              background: 'var(--color-secondary)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: '#ffffff',
              fontSize: '1.4rem',
            }}
          >
            📡
          </div>
          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <span style={{ fontSize: '0.75rem', fontWeight: 800, color: 'var(--color-secondary)', letterSpacing: '0.06em' }}>
                LIVE FIELD SIGNALS · MATALE & BADULLA CORRIDORS
              </span>
              <span className="badge badge-emerald">Freshly Moderated</span>
            </div>
            <h3 style={{ fontSize: '1.15rem', fontWeight: 700, margin: '4px 0 2px 0', color: 'var(--color-primary)' }}>
              Sigiriya & Nine Arch Bridge Current Conditions
            </h3>
            <p style={{ fontSize: '0.88rem', color: 'var(--color-text-muted)', margin: 0 }}>
              Sigiriya summit dry and clear (06:45 AM). Knuckles Corbet&apos;s Gap afternoon shower warning active.
            </p>
          </div>
        </div>

        <div style={{ display: 'flex', gap: '12px' }}>
          <button
            onClick={() => setSelectedType('FIELD_REPORT')}
            className="btn btn-secondary"
            style={{ fontSize: '0.85rem', padding: '8px 16px' }}
          >
            View 4 Fresh Field Reports
          </button>
        </div>
      </div>

      {/* 4. Moments Feed Grid */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fill, minmax(360px, 1fr))',
          gap: '24px',
        }}
      >
        {filteredPosts.map((post) => {
          const isSaved = savedPostIds.has(post.id);
          const isHelpful = helpfulPostIds.has(post.id);

          return (
            <article
              key={post.id}
              style={{
                background: 'var(--color-surface)',
                borderRadius: 'var(--radius-md)',
                border: '1px solid var(--color-border)',
                overflow: 'hidden',
                display: 'flex',
                flexDirection: 'column',
                boxShadow: 'var(--shadow-card)',
                transition: 'transform 0.2s ease, box-shadow 0.2s ease',
              }}
            >
              {/* Card Header: Author & Badge */}
              <div
                style={{
                  padding: '16px 18px 12px 18px',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  borderBottom: '1px solid rgba(0,0,0,0.04)',
                }}
              >
                <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                  <img
                    src={post.authorAvatar}
                    alt={post.authorName}
                    style={{
                      width: '40px',
                      height: '40px',
                      borderRadius: '50%',
                      objectFit: 'cover',
                      border: '1.5px solid var(--color-border)',
                    }}
                  />
                  <div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                      <span style={{ fontWeight: 700, fontSize: '0.95rem', color: 'var(--color-text)' }}>
                        {post.authorName}
                      </span>
                      {post.authorBadge === 'LICENSED_GUIDE' && (
                        <span
                          style={{
                            background: 'rgba(7, 59, 92, 0.1)',
                            color: 'var(--color-primary)',
                            fontSize: '0.65rem',
                            fontWeight: 800,
                            padding: '2px 6px',
                            borderRadius: '4px',
                          }}
                        >
                          LICENSED GUIDE
                        </span>
                      )}
                      {post.authorBadge === 'VERIFIED_VISITOR' && (
                        <span
                          style={{
                            background: 'rgba(8, 126, 139, 0.1)',
                            color: 'var(--color-secondary)',
                            fontSize: '0.65rem',
                            fontWeight: 800,
                            padding: '2px 6px',
                            borderRadius: '4px',
                          }}
                        >
                          VERIFIED VISITOR
                        </span>
                      )}
                    </div>
                    <span style={{ fontSize: '0.75rem', color: 'var(--color-text-muted)' }}>
                      {post.publishedAt} · {post.districtName} District
                    </span>
                  </div>
                </div>

                {/* Freshness / Type Pill */}
                {post.postType === 'FIELD_REPORT' ? (
                  <span
                    style={{
                      background: 'rgba(8, 126, 139, 0.12)',
                      color: 'var(--color-secondary)',
                      fontSize: '0.75rem',
                      fontWeight: 700,
                      padding: '4px 8px',
                      borderRadius: 'var(--radius-pill)',
                      border: '1px solid rgba(8, 126, 139, 0.3)',
                    }}
                  >
                    ⏱️ Current Report
                  </span>
                ) : post.postType === 'QUESTION' ? (
                  <span
                    style={{
                      background: post.isQuestionResolved ? 'rgba(8, 126, 139, 0.1)' : 'rgba(245, 158, 11, 0.12)',
                      color: post.isQuestionResolved ? 'var(--color-secondary)' : '#D97706',
                      fontSize: '0.75rem',
                      fontWeight: 700,
                      padding: '4px 8px',
                      borderRadius: 'var(--radius-pill)',
                    }}
                  >
                    {post.isQuestionResolved ? '✓ Resolved Q&A' : '❓ Open Question'}
                  </span>
                ) : (
                  <span
                    style={{
                      background: 'rgba(0,0,0,0.04)',
                      color: 'var(--color-text-muted)',
                      fontSize: '0.75rem',
                      fontWeight: 600,
                      padding: '4px 8px',
                      borderRadius: 'var(--radius-pill)',
                    }}
                  >
                    📸 Moment
                  </span>
                )}
              </div>

              {/* Media Image */}
              {post.media.length > 0 && (
                <div style={{ position: 'relative', height: '220px', width: '100%', overflow: 'hidden' }}>
                  <img
                    src={post.media[0].mediaUrl}
                    alt={post.destinationName || post.caption}
                    style={{
                      width: '100%',
                      height: '100%',
                      objectFit: 'cover',
                      display: 'block',
                      transition: 'transform 0.3s ease',
                    }}
                  />
                  {post.destinationName && (
                    <div
                      style={{
                        position: 'absolute',
                        bottom: '12px',
                        left: '12px',
                        background: 'rgba(0, 0, 0, 0.65)',
                        backdropFilter: 'blur(4px)',
                        color: '#ffffff',
                        padding: '4px 10px',
                        borderRadius: 'var(--radius-pill)',
                        fontSize: '0.8rem',
                        fontWeight: 700,
                        display: 'flex',
                        alignItems: 'center',
                        gap: '4px',
                      }}
                    >
                      <span style={{ color: 'var(--color-accent)' }}>📍</span> {post.destinationName}
                    </div>
                  )}
                </div>
              )}

              {/* Caption & Body */}
              <div style={{ padding: '16px 18px', flex: 1 }}>
                <p style={{ fontSize: '0.92rem', lineHeight: 1.55, color: 'var(--color-text)', margin: 0 }}>
                  {post.caption}
                </p>

                {/* Canonical Island Atlas Tag Pill */}
                <div style={{ marginTop: '12px', display: 'flex', gap: '8px', flexWrap: 'wrap' }}>
                  <Link
                    href={`/atlas`}
                    style={{
                      fontSize: '0.75rem',
                      fontWeight: 700,
                      color: 'var(--color-secondary)',
                      background: 'rgba(8, 126, 139, 0.08)',
                      padding: '3px 8px',
                      borderRadius: '6px',
                      textDecoration: 'none',
                    }}
                  >
                    🧭 Island Atlas · {post.districtName}
                  </Link>

                  {post.observedAt && (
                    <span style={{ fontSize: '0.75rem', color: 'var(--color-text-muted)', alignSelf: 'center' }}>
                      Observed: {post.observedAt}
                    </span>
                  )}
                </div>

                {/* Accepted Answer Preview if Available */}
                {post.comments.length > 0 && post.comments.some((c) => c.isAcceptedAnswer) && (
                  <div
                    style={{
                      marginTop: '14px',
                      background: 'rgba(8, 126, 139, 0.05)',
                      border: '1px solid rgba(8, 126, 139, 0.2)',
                      borderRadius: 'var(--radius-sm)',
                      padding: '10px 12px',
                    }}
                  >
                    <div style={{ display: 'flex', alignItems: 'center', gap: '6px', marginBottom: '4px' }}>
                      <span style={{ color: 'var(--color-secondary)', fontSize: '0.8rem', fontWeight: 800 }}>
                        ✓ Accepted Local Answer
                      </span>
                      <span style={{ fontSize: '0.72rem', color: 'var(--color-text-muted)' }}>
                        by {post.comments.find((c) => c.isAcceptedAnswer)?.authorName}
                      </span>
                    </div>
                    <p style={{ fontSize: '0.82rem', margin: 0, color: 'var(--color-text)', lineHeight: 1.4 }}>
                      &ldquo;{post.comments.find((c) => c.isAcceptedAnswer)?.commentText}&rdquo;
                    </p>
                  </div>
                )}
              </div>

              {/* Action Toolbar */}
              <div
                style={{
                  padding: '12px 18px',
                  borderTop: '1px solid var(--color-border)',
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  background: 'rgba(0,0,0,0.015)',
                }}
              >
                <div style={{ display: 'flex', gap: '12px', alignItems: 'center' }}>
                  <button
                    onClick={() => toggleHelpful(post.id)}
                    style={{
                      background: 'none',
                      border: 'none',
                      cursor: 'pointer',
                      display: 'flex',
                      alignItems: 'center',
                      gap: '4px',
                      fontSize: '0.82rem',
                      fontWeight: 700,
                      color: isHelpful ? 'var(--color-secondary)' : 'var(--color-text-muted)',
                    }}
                  >
                    <span>{isHelpful ? '👍' : '👍🏻'}</span>
                    <span>Helpful ({post.helpfulCount})</span>
                  </button>

                  <button
                    onClick={() => toggleSave(post.id)}
                    style={{
                      background: 'none',
                      border: 'none',
                      cursor: 'pointer',
                      fontSize: '0.82rem',
                      color: isSaved ? 'var(--color-accent)' : 'var(--color-text-muted)',
                      fontWeight: 600,
                    }}
                  >
                    {isSaved ? '🔖 Saved' : '🔖 Save'}
                  </button>
                </div>

                <div style={{ display: 'flex', gap: '8px' }}>
                  <button
                    onClick={() => handleValidateItinerary(post)}
                    style={{
                      background: 'var(--color-primary)',
                      color: '#ffffff',
                      border: 'none',
                      borderRadius: 'var(--radius-sm)',
                      padding: '6px 12px',
                      fontSize: '0.8rem',
                      fontWeight: 700,
                      cursor: 'pointer',
                      display: 'flex',
                      alignItems: 'center',
                      gap: '4px',
                    }}
                  >
                    <span>➕ Add to Trip</span>
                  </button>

                  <button
                    onClick={() => setInquiryPost(post)}
                    style={{
                      background: 'rgba(8, 126, 139, 0.1)',
                      color: 'var(--color-secondary)',
                      border: '1px solid rgba(8, 126, 139, 0.25)',
                      borderRadius: 'var(--radius-sm)',
                      padding: '6px 10px',
                      fontSize: '0.8rem',
                      fontWeight: 700,
                      cursor: 'pointer',
                    }}
                  >
                    💬 Inquire
                  </button>
                </div>
              </div>
            </article>
          );
        })}
      </div>

      {/* 5. TripGraph Feasibility Modal */}
      {validatingPost && (
        <div
          style={{
            position: 'fixed',
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            backgroundColor: 'rgba(7, 59, 92, 0.65)',
            backdropFilter: 'blur(5px)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            zIndex: 1000,
            padding: '20px',
          }}
        >
          <div
            style={{
              backgroundColor: 'var(--color-surface)',
              borderRadius: 'var(--radius-lg)',
              maxWidth: '540px',
              width: '100%',
              padding: '28px',
              boxShadow: '0 20px 50px rgba(0,0,0,0.3)',
              border: '1.5px solid var(--color-border)',
            }}
          >
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <span style={{ fontSize: '1.4rem' }}>🧭</span>
                <div>
                  <h3 style={{ margin: 0, fontSize: '1.25rem', color: 'var(--color-primary)' }}>
                    TripGraph Feasibility Check
                  </h3>
                  <span style={{ fontSize: '0.78rem', color: 'var(--color-text-muted)' }}>
                    Automated Corridor Route Validation
                  </span>
                </div>
              </div>
              <button
                onClick={() => {
                  setValidatingPost(null);
                  setTripGraphResult(null);
                }}
                style={{ background: 'none', border: 'none', fontSize: '1.4rem', cursor: 'pointer', color: 'var(--color-text-muted)' }}
              >
                ✕
              </button>
            </div>

            <div style={{ background: 'rgba(0,0,0,0.03)', padding: '14px', borderRadius: 'var(--radius-sm)', marginBottom: '18px' }}>
              <div style={{ fontSize: '0.85rem', fontWeight: 700, color: 'var(--color-text)' }}>
                Destination: {validatingPost.destinationName || validatingPost.districtName}
              </div>
              <div style={{ fontSize: '0.78rem', color: 'var(--color-text-muted)', marginTop: '2px' }}>
                Tagged District: {validatingPost.districtName} · Verified Atlas Node
              </div>
            </div>

            {tripGraphResult ? (
              <div>
                <div
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '10px',
                    padding: '12px 14px',
                    borderRadius: 'var(--radius-sm)',
                    background: 'rgba(8, 126, 139, 0.1)',
                    border: '1px solid rgba(8, 126, 139, 0.3)',
                    marginBottom: '16px',
                  }}
                >
                  <span style={{ fontSize: '1.2rem', color: 'var(--color-secondary)' }}>✓</span>
                  <div>
                    <div style={{ fontSize: '0.9rem', fontWeight: 800, color: 'var(--color-secondary)' }}>
                      TripGraph Validated: Feasible Addition
                    </div>
                    <div style={{ fontSize: '0.8rem', color: 'var(--color-text-muted)' }}>
                      Recommended: {tripGraphResult.recommendedWindow}
                    </div>
                  </div>
                </div>

                <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', marginBottom: '20px' }}>
                  {tripGraphResult.notes.map((note, i) => (
                    <div key={i} style={{ display: 'flex', gap: '8px', fontSize: '0.82rem', color: 'var(--color-text)' }}>
                      <span style={{ color: 'var(--color-secondary)' }}>•</span>
                      <span>{note}</span>
                    </div>
                  ))}
                </div>

                <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px' }}>
                  <button
                    onClick={() => {
                      setValidatingPost(null);
                      setTripGraphResult(null);
                    }}
                    className="btn btn-secondary"
                  >
                    Cancel
                  </button>
                  <button
                    onClick={() => {
                      alert(`Successfully added ${validatingPost.destinationName || validatingPost.districtName} to your draft Day 1 Trip Canvas!`);
                      setValidatingPost(null);
                      setTripGraphResult(null);
                    }}
                    className="btn btn-primary"
                  >
                    Confirm Addition to Trip Canvas
                  </button>
                </div>
              </div>
            ) : (
              <div style={{ textAlign: 'center', padding: '24px 0', color: 'var(--color-text-muted)' }}>
                Evaluating route geometry, mountain road buffers, and opening hours...
              </div>
            )}
          </div>
        </div>
      )}

      {/* 6. Contextual Provider Inquiry Modal */}
      {inquiryPost && (
        <div
          style={{
            position: 'fixed',
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            backgroundColor: 'rgba(7, 59, 92, 0.65)',
            backdropFilter: 'blur(5px)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            zIndex: 1000,
            padding: '20px',
          }}
        >
          <div
            style={{
              backgroundColor: 'var(--color-surface)',
              borderRadius: 'var(--radius-lg)',
              maxWidth: '520px',
              width: '100%',
              padding: '28px',
              boxShadow: '0 20px 50px rgba(0,0,0,0.3)',
              border: '1.5px solid var(--color-border)',
            }}
          >
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <span style={{ fontSize: '1.4rem' }}>💬</span>
                <div>
                  <h3 style={{ margin: 0, fontSize: '1.25rem', color: 'var(--color-primary)' }}>
                    Contextual Messenger Inquiry
                  </h3>
                  <span style={{ fontSize: '0.78rem', color: 'var(--color-text-muted)' }}>
                    Structured Traveller-to-Provider Thread
                  </span>
                </div>
              </div>
              <button
                onClick={() => {
                  setInquiryPost(null);
                  setInquirySent(false);
                }}
                style={{ background: 'none', border: 'none', fontSize: '1.4rem', cursor: 'pointer', color: 'var(--color-text-muted)' }}
              >
                ✕
              </button>
            </div>

            {inquirySent ? (
              <div style={{ textAlign: 'center', padding: '20px 0' }}>
                <div style={{ fontSize: '2.5rem', marginBottom: '12px' }}>✉️</div>
                <h4 style={{ color: 'var(--color-secondary)', fontSize: '1.1rem', marginBottom: '6px' }}>
                  Inquiry Dispatched to {inquiryPost.authorName}
                </h4>
                <p style={{ fontSize: '0.85rem', color: 'var(--color-text-muted)', lineHeight: 1.5 }}>
                  A structured conversation thread with idempotency key has been initialized. The provider will respond via your Travel Messenger inbox.
                </p>
                <button
                  onClick={() => {
                    setInquiryPost(null);
                    setInquirySent(false);
                  }}
                  className="btn btn-primary"
                  style={{ marginTop: '16px' }}
                >
                  Close & Continue
                </button>
              </div>
            ) : (
              <form
                onSubmit={(e) => {
                  e.preventDefault();
                  setInquirySent(true);
                }}
              >
                <div style={{ background: 'rgba(0,0,0,0.03)', padding: '12px', borderRadius: 'var(--radius-sm)', marginBottom: '16px' }}>
                  <div style={{ fontSize: '0.85rem', fontWeight: 700 }}>
                    Recipient: {inquiryPost.authorName} ({inquiryPost.authorBadge.replace('_', ' ')})
                  </div>
                  <div style={{ fontSize: '0.78rem', color: 'var(--color-text-muted)' }}>
                    Tagged Experience: {inquiryPost.destinationName || inquiryPost.districtName}
                  </div>
                </div>

                <div style={{ marginBottom: '14px' }}>
                  <label style={{ display: 'block', fontSize: '0.82rem', fontWeight: 700, marginBottom: '6px' }}>
                    Proposed Visit Date
                  </label>
                  <input
                    type="date"
                    value={inquiryDate}
                    onChange={(e) => setInquiryDate(e.target.value)}
                    style={{
                      width: '100%',
                      padding: '10px 12px',
                      borderRadius: 'var(--radius-sm)',
                      border: '1px solid var(--color-border)',
                      fontSize: '0.9rem',
                    }}
                  />
                </div>

                <div style={{ marginBottom: '14px' }}>
                  <label style={{ display: 'block', fontSize: '0.82rem', fontWeight: 700, marginBottom: '6px' }}>
                    Party Size (Guests)
                  </label>
                  <input
                    type="number"
                    min="1"
                    max="20"
                    value={inquiryGuests}
                    onChange={(e) => setInquiryGuests(parseInt(e.target.value) || 1)}
                    style={{
                      width: '100%',
                      padding: '10px 12px',
                      borderRadius: 'var(--radius-sm)',
                      border: '1px solid var(--color-border)',
                      fontSize: '0.9rem',
                    }}
                  />
                </div>

                <div style={{ marginBottom: '20px' }}>
                  <label style={{ display: 'block', fontSize: '0.82rem', fontWeight: 700, marginBottom: '6px' }}>
                    Specific Inquiries or Logistics Notes
                  </label>
                  <textarea
                    rows={3}
                    defaultValue={`Hello ${inquiryPost.authorName}, we saw your report on TRAVERZA Community regarding ${inquiryPost.destinationName || inquiryPost.districtName}. Are you available for a guided session or service quote on this date?`}
                    style={{
                      width: '100%',
                      padding: '10px 12px',
                      borderRadius: 'var(--radius-sm)',
                      border: '1px solid var(--color-border)',
                      fontSize: '0.88rem',
                    }}
                  />
                </div>

                <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px' }}>
                  <button
                    type="button"
                    onClick={() => setInquiryPost(null)}
                    className="btn btn-secondary"
                  >
                    Cancel
                  </button>
                  <button type="submit" className="btn btn-primary">
                    Send Structured Inquiry
                  </button>
                </div>
              </form>
            )}
          </div>
        </div>
      )}

      {/* 7. Create Moment Modal */}
      {showCreateModal && (
        <div
          style={{
            position: 'fixed',
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            backgroundColor: 'rgba(7, 59, 92, 0.65)',
            backdropFilter: 'blur(5px)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            zIndex: 1000,
            padding: '20px',
          }}
        >
          <div
            style={{
              backgroundColor: 'var(--color-surface)',
              borderRadius: 'var(--radius-lg)',
              maxWidth: '560px',
              width: '100%',
              padding: '28px',
              boxShadow: '0 20px 50px rgba(0,0,0,0.3)',
              border: '1.5px solid var(--color-border)',
            }}
          >
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <span style={{ fontSize: '1.4rem' }}>📸</span>
                <div>
                  <h3 style={{ margin: 0, fontSize: '1.25rem', color: 'var(--color-primary)' }}>
                    Share a Community Moment
                  </h3>
                  <span style={{ fontSize: '0.78rem', color: 'var(--color-text-muted)' }}>
                    Structured Island Atlas Tagging · EXIF GPS Stripped
                  </span>
                </div>
              </div>
              <button
                onClick={() => setShowCreateModal(false)}
                style={{ background: 'none', border: 'none', fontSize: '1.4rem', cursor: 'pointer', color: 'var(--color-text-muted)' }}
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleCreatePost}>
              <div style={{ marginBottom: '14px' }}>
                <label style={{ display: 'block', fontSize: '0.82rem', fontWeight: 700, marginBottom: '6px' }}>
                  Contribution Type
                </label>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '8px' }}>
                  {[
                    { id: 'PHOTO', label: '📸 Visual Moment' },
                    { id: 'FIELD_REPORT', label: '⏱️ Field Report' },
                    { id: 'QUESTION', label: '❓ Place Question' },
                    { id: 'LOCAL_NOTE', label: '💡 Practical Note' },
                  ].map((t) => (
                    <button
                      type="button"
                      key={t.id}
                      onClick={() => setNewType(t.id as 'PHOTO' | 'FIELD_REPORT' | 'QUESTION' | 'LOCAL_NOTE')}
                      style={{
                        padding: '10px',
                        borderRadius: 'var(--radius-sm)',
                        fontSize: '0.82rem',
                        fontWeight: 700,
                        border: newType === t.id ? '2px solid var(--color-secondary)' : '1px solid var(--color-border)',
                        background: newType === t.id ? 'rgba(8, 126, 139, 0.1)' : 'var(--color-surface)',
                        color: newType === t.id ? 'var(--color-secondary)' : 'var(--color-text)',
                        cursor: 'pointer',
                      }}
                    >
                      {t.label}
                    </button>
                  ))}
                </div>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px', marginBottom: '14px' }}>
                <div>
                  <label style={{ display: 'block', fontSize: '0.82rem', fontWeight: 700, marginBottom: '6px' }}>
                    District (Sri Lanka 25)
                  </label>
                  <select
                    value={newDistrict}
                    onChange={(e) => setNewDistrict(e.target.value)}
                    style={{
                      width: '100%',
                      padding: '10px 12px',
                      borderRadius: 'var(--radius-sm)',
                      border: '1px solid var(--color-border)',
                      fontSize: '0.88rem',
                    }}
                  >
                    {SRI_LANKA_DISTRICTS.filter((d) => d.id !== 'all').map((d) => (
                      <option key={d.id} value={d.id}>
                        {d.name}
                      </option>
                    ))}
                  </select>
                </div>

                <div>
                  <label style={{ display: 'block', fontSize: '0.82rem', fontWeight: 700, marginBottom: '6px' }}>
                    Destination Landmark
                  </label>
                  <input
                    type="text"
                    value={newDestination}
                    onChange={(e) => setNewDestination(e.target.value)}
                    placeholder="e.g. Pidurangala Rock"
                    style={{
                      width: '100%',
                      padding: '10px 12px',
                      borderRadius: 'var(--radius-sm)',
                      border: '1px solid var(--color-border)',
                      fontSize: '0.88rem',
                    }}
                  />
                </div>
              </div>

              <div style={{ marginBottom: '16px' }}>
                <label style={{ display: 'block', fontSize: '0.82rem', fontWeight: 700, marginBottom: '6px' }}>
                  Caption / Field Report Details
                </label>
                <textarea
                  rows={4}
                  value={newCaption}
                  onChange={(e) => setNewCaption(e.target.value)}
                  placeholder="Share practical context: trail surface, morning queues, family suitability, water availability..."
                  style={{
                    width: '100%',
                    padding: '12px',
                    borderRadius: 'var(--radius-sm)',
                    border: '1px solid var(--color-border)',
                    fontSize: '0.88rem',
                    lineHeight: 1.45,
                  }}
                  required
                />
              </div>

              <div
                style={{
                  background: 'rgba(8, 126, 139, 0.06)',
                  padding: '10px 12px',
                  borderRadius: 'var(--radius-sm)',
                  fontSize: '0.78rem',
                  color: 'var(--color-secondary)',
                  marginBottom: '18px',
                }}
              >
                🔒 <strong>Privacy Assurance:</strong> GPS EXIF coordinates are scrubbed during upload. Your live GPS location is never made public.
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px' }}>
                <button
                  type="button"
                  onClick={() => setShowCreateModal(false)}
                  className="btn btn-secondary"
                >
                  Cancel
                </button>
                <button type="submit" className="btn btn-primary">
                  Publish to Community
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
