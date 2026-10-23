import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  const targetPhones = ['+919072775343', '9072775343'];
  console.log(`Checking for records with phones:`, targetPhones);

  // Delete OTPs
  const deletedOtps = await prisma.otpVerification.deleteMany({
    where: {
      phone: { in: targetPhones },
    },
  });
  console.log(`Deleted ${deletedOtps.count} OTP verification records.`);

  // Find users
  const users = await prisma.user.findMany({
    where: {
      phone: { in: targetPhones },
    },
  });
  console.log(`Found ${users.length} users:`, users.map(u => ({ id: u.id, phone: u.phone, email: u.email })));

  for (const user of users) {
    // Delete user (cascades profiles, refresh tokens, sessions, oauth)
    await prisma.user.delete({
      where: { id: user.id },
    });
    console.log(`Deleted user ${user.id} (${user.phone})`);
  }

  console.log('Cleanup completed successfully.');
}

main()
  .catch((e) => {
    console.error('Error during cleanup:', e);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
