-- ============================================================
-- Fix User Passwords - Run this on FreeSQLDatabase.com
-- The original BCrypt hashes were incorrect placeholders.
-- These are the CORRECT hashes for the stated passwords.
-- ============================================================

-- Admin: admin123
UPDATE users SET password = '$2a$10$QSnHurm1WVhUwKgagbH9m.FurStndJ3dbb4WZGRVBVw1l/0KM4jZC'
WHERE email = 'admin@revworkforce.com';

-- Manager: manager123
UPDATE users SET password = '$2a$10$Gm9DsKCFXtVlOZLA0IUM2uJCYsYJOp2H7ePdv27KaNzUlvcveD2ay'
WHERE email = 'manager@revworkforce.com';

-- Employees: employee123
UPDATE users SET password = '$2a$10$ozcV4fgBLXmBpQFNbrjfP.XIsZb5dL7obGUeNAXaxAsiOEDj9zk3q'
WHERE email = 'employee@revworkforce.com';

UPDATE users SET password = '$2a$10$ozcV4fgBLXmBpQFNbrjfP.XIsZb5dL7obGUeNAXaxAsiOEDj9zk3q'
WHERE email = 'amit@revworkforce.com';

UPDATE users SET password = '$2a$10$ozcV4fgBLXmBpQFNbrjfP.XIsZb5dL7obGUeNAXaxAsiOEDj9zk3q'
WHERE email = 'sneha@revworkforce.com';

COMMIT;

-- Verify the update
SELECT email, password FROM users;
