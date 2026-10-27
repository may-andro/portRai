import { initializeApp } from 'firebase-admin/app';

initializeApp();

// Every deployed function is exported here, one line per feature.
export {
  callRequestCreated,
  callRequestDecided,
  getCallSlots,
  requestCall,
} from './call_booking/call_booking.js';
export { fetchJobOpenings } from './job_opening/fetch_job_openings.js';
export {
  portfolioUpdates,
  sendPortfolioUpdates,
} from './portfolio_update/portfolio_updates.js';
