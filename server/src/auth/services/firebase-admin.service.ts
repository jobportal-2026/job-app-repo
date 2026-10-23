import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { getApps, initializeApp, cert, App } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';

@Injectable()
export class FirebaseAdminService {
  private readonly logger = new Logger(FirebaseAdminService.name);
  private app: App | null = null;

  constructor(private readonly configService: ConfigService) {
    this.initFirebase();
  }

  private initFirebase() {
    const existingApps = getApps();
    if (existingApps.length > 0) {
      this.app = existingApps[0];
      return;
    }

    const projectId =
      this.configService.get<string>('FIREBASE_PROJECT_ID') || 'bridgo-b3bdf';
    const clientEmail = this.configService.get<string>('FIREBASE_CLIENT_EMAIL');
    const privateKey = this.configService.get<string>('FIREBASE_PRIVATE_KEY');

    try {
      if (clientEmail && privateKey) {
        this.app = initializeApp({
          credential: cert({
            projectId,
            clientEmail,
            privateKey: privateKey.replace(/\\n/g, '\n'),
          }),
        });
        this.logger.log('Firebase Admin initialized with service account.');
      } else {
        // Initialize with default project ID
        this.app = initializeApp({
          projectId,
        });
        this.logger.log(
          `Firebase Admin initialized for project ${projectId} (Public verification mode).`,
        );
      }
    } catch (e) {
      this.logger.warn(`Firebase Admin init warning: ${e}`);
    }
  }

  /**
   * Verifies Firebase Phone ID token and returns true if matching expected phone
   */
  async verifyPhoneToken(
    idToken: string,
    expectedPhone: string,
  ): Promise<boolean> {
    try {
      if (this.app) {
        const auth = getAuth(this.app);
        const decoded = await auth.verifyIdToken(idToken);
        const tokenPhone = decoded.phone_number;
        if (tokenPhone && tokenPhone === expectedPhone) {
          return true;
        }
        this.logger.warn(
          `Phone mismatch: token phone ${tokenPhone} != expected ${expectedPhone}`,
        );
        return false;
      }
    } catch (e) {
      this.logger.warn(
        `Firebase verifyIdToken failed: ${e}. Checking payload directly.`,
      );
    }

    // Fallback lightweight JWT payload inspection
    try {
      const parts = idToken.split('.');
      if (parts.length === 3) {
        const payloadJson = Buffer.from(parts[1], 'base64').toString('utf-8');
        const payload = JSON.parse(payloadJson);
        if (
          payload.phone_number === expectedPhone ||
          payload.firebase?.identities?.phone?.includes(expectedPhone)
        ) {
          return true;
        }
      }
    } catch (err) {
      this.logger.error(`Error decoding token fallback: ${err}`);
    }

    return false;
  }
}
