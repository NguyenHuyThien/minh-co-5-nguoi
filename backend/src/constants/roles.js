// Define available user roles for the application

const USER_ROLES = {
  CUSTOMER: 'customer',
  MERCHANT: 'merchant',
  SHOPPER: 'shopper',
  // Admin role is reserved and should not be assignable via registration
  ADMIN: 'admin',
};

module.exports = {
  USER_ROLES,
};
